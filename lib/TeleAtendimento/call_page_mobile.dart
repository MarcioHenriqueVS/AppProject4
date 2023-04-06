import 'dart:math';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';

const appId = '02cf1302bb464221a9b1cb5355d622b7';

class CallPageMobile extends StatefulWidget {

  final String? channelName;
  final String? token;

  const CallPageMobile({Key? key, this.channelName, this.token}) : super(key: key);

  @override
  State<CallPageMobile> createState() => _CallPageMobileState();
}

class _CallPageMobileState extends State<CallPageMobile> {

  final users = <int>[];
  final infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;
  var _remoteUid;

  @override void initState() {
    super.initState();
    initialize();
  }

  @override void dispose() {
    users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    _addAgoraEventHandlers();
    await _engine.joinChannel(widget.token, widget.channelName!, null, 0);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {},
        userJoined: (int uid, int elapsed) {
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          setState(() {
            _remoteUid = null;
          });
        }));
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              _engine.muteLocalAudioStream(muted);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20,
            ),
          ),
          RawMaterialButton(
            onPressed: () => Navigator.pop(context),
            shape: const CircleBorder(),
            elevation: 2,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              _engine.switchCamera();
            },
            shape: const CircleBorder(),
            elevation: 2,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoCall'),
      ),
      body: Stack(
        children: [
          Center(
            child: _renderRemoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 100,
              child: Center(
                child: _renderLocalPreview(),
              ),
            ),
          ),
          _toolbar(),
        ],
      ),
    );
  }

  Widget _renderLocalPreview() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery
            .of(context)
            .size
            .width,
        maxHeight: MediaQuery
            .of(context)
            .size
            .height,
      ),
      child: AspectRatio(
        aspectRatio: 3 / 4, // Ajuste a proporção conforme necessário
        child: Transform.rotate(
          angle: 360 * pi / 180,
          child: rtc_local_view.SurfaceView(),
        ),
      ),
    );
  }


  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery
              .of(context)
              .size
              .width,
          maxHeight: MediaQuery
              .of(context)
              .size
              .height,
        ),
        child: AspectRatio(
          aspectRatio: 3 / 4, // Ajuste a proporção conforme necessário
          child: rtc_remote_view.SurfaceView(
            uid: _remoteUid,
            channelId: widget.channelName!,
          ),
        ),
      );
    } else {
      return const Text(
        'Aguarde o outro usuário entrar na chamada',
        textAlign: TextAlign.center,
      );
    }
  }
}