import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/pages/video_call/video_call_bloc.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_firebase_chat/src/utils/settings.dart';
import 'package:flutter_firebase_chat/src/widgets/raw_icon_button.dart';

class VideoCallPage extends StatefulWidget {
  @override
  VideoCallPageState createState() => VideoCallPageState();
}

class VideoCallPageState extends State<VideoCallPage> {
  VideoCallBloc _videoCallBloc;

  void _onToggleMute() {
    _videoCallBloc.add(VideoCallMuteAudioEvent());
  }

  void _onSwitchCamera() {
    _videoCallBloc.add(VideoCallSwitchCameraEvent());
  }

  @override
  void initState() {
    super.initState();
    AgoraRtcEngine.create(AGORA_APP_ID);
    _videoCallBloc = BlocProvider.of<VideoCallBloc>(context);
    _videoCallBloc.add(VideoCallInitEvent());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => Future.value(true),
        child: Scaffold(
            backgroundColor: blackColor,
            body: BlocBuilder<VideoCallBloc, VideoCallState>(
                builder: (_, state) => Stack(children: [
                      _buildUserRenderWidget(state.userId),
                      _buildToolbar(state.muted)
                    ]))));
  }

  Widget _buildUserRenderWidget(int userId) {
    // if (userId != null)
    //   return AgoraRenderWidget(userId);
    // else
    return Center(
      child: CircleAvatar(
        maxRadius: 150,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.blueGrey,
        child: Icon(
          Icons.call,
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }

  Widget _buildToolbar(bool muted) {
    return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: SafeArea(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            RawIconButton(
                padding: EdgeInsets.all(12),
                icon: Icon(muted ? Icons.mic_off : Icons.mic,
                    color: blackColor, size: 30),
                shape: CircleBorder(),
                fillColor: Colors.white,
                onPressed: _onToggleMute),
            RawIconButton(
                padding: EdgeInsets.all(15),
                icon: Icon(Icons.call_end, color: whiteColor, size: 30),
                shape: CircleBorder(),
                fillColor: Colors.red,
                onPressed: () => Navigator.pop(context)),
          ])
        ])));
  }
}
