import 'dart:math';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;

const appId = '02cf1302bb464221a9b1cb5355d622b7';

class CallPage extends StatefulWidget {
  final String token;
  final String channelName;

  const CallPage({
    Key? key,
    required this.token,
    required this.channelName,
  }) : super(key: key);


  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  var _remoteUid;
  late RtcEngine _engine;
  bool muted = false;
  final _users = <int>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initForAgora();
    });
  }
  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initForAgora() async {

    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    await _engine.enableVideo();
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
    await _engine.joinChannel(widget.token, widget.channelName, null, 0);
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
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
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
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: AspectRatio(
          aspectRatio: 3 / 4, // Ajuste a proporção conforme necessário
          child: rtc_remote_view.SurfaceView(
            uid: _remoteUid,
            channelId: widget.channelName,
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


  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(onPressed: (){
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
          RawMaterialButton(onPressed: () => Navigator.pop(context),
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
          RawMaterialButton(onPressed: () {
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
}