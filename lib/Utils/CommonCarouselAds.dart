import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommonCarouselAds extends StatefulWidget {
  final List<String> media;
  final double height;

  const CommonCarouselAds({
    super.key,
    required this.media,
    this.height = 150,
  });

  @override
  State<CommonCarouselAds> createState() => _CommonCarouselAdsState();
}

class _CommonCarouselAdsState extends State<CommonCarouselAds> {
  bool isVideoPlaying = false;

  @override
  Widget build(BuildContext context) {
    print("🎯 Media List: ${widget.media}");
    if (widget.media.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: _fallbackImage(), // ✅ Show fallback image instead of spinner
      );
    }

    return CarouselSlider.builder(
      itemCount: widget.media.length,
      itemBuilder: (context, index, realIndex) {
        String mediaPath = widget.media[index];

        if (_isVideo(mediaPath)) {
          return _buildVideoItem(mediaPath);
        } else {
          return _buildImageItem(mediaPath);
        }
      },
      options: CarouselOptions(
        height: widget.height,
        autoPlay: !isVideoPlaying, // ✅ Stop autoplay when a video is playing
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.9,
        autoPlayCurve: Curves.fastOutSlowIn,
        autoPlayAnimationDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  // ✅ Detects YouTube and MP4 videos
  bool _isVideo(String path) {
    return path.endsWith(".mp4") ||
        path.endsWith(".mov") ||
        path.endsWith(".avi") ||
        path.endsWith(".mkv") ||
        _isYouTube(path);
  }

  bool _isYouTube(String url) {
    final youtubePattern = RegExp(
        r"^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/(watch\?v=|embed\/|shorts\/|playlist\?|.+)");
    return youtubePattern.hasMatch(url);
  }

  String convertYouTubeToEmbed(String url) {
    final RegExp regExp = RegExp(
        r"(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[\?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})");

    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      String videoId = match.group(1)!;
      return "https://www.youtube.com/embed/$videoId";
    }
    return url;
  }

  Widget _buildVideoItem(String videoPath) {
    if (_isYouTube(videoPath)) {
      String embedUrl = convertYouTubeToEmbed(videoPath);

      WebViewController webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..loadRequest(Uri.parse(embedUrl));

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: WebViewWidget(controller: webViewController),
        ),
      );
    }

    return VideoPlayerWidget(videoPath: videoPath);
  }

  Widget _buildImageItem(String imagePath) {
    if (imagePath.startsWith('data:image')) {
      try {
        final base64Data = imagePath.split(',').last;
        final decodedBytes = base64Decode(base64Data);
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            decodedBytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: widget.height,
          ),
        );
      } catch (e) {
        print("❌ Failed to decode base64 image: $e");
        return _fallbackImage();
      }
    }

    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          print("❌ Image Load Error: $error");
          return _fallbackImage();
        },
      );
    }

    print("❌ Unknown image format: $imagePath");
    return _fallbackImage();
  }

  bool _isBase64(String data) {
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(data) && (data.length % 4 == 0);
  }

  Widget _fallbackImage() {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset("assets/ads.png",
            fit: BoxFit.cover, width: double.infinity, height: widget.height),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({Key? key, required this.videoPath})
      : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  // ✅ Initialize Video Controller & Chewie
  void _initializeVideo() {
    print("🎥 Initializing Video: ${widget.videoPath}");

    _videoController = VideoPlayerController.network(widget.videoPath);

    _videoController.initialize().then((_) {
      print("✅ Video Initialized Successfully: ${widget.videoPath}");
      if (mounted) {
        setState(() {
          _videoController.setLooping(true);
          _videoController.play();
          _isError = false;
          _initializeChewieController(); // ✅ Initialize Chewie after video is ready
        });
      }
    }).catchError((error) {
      print("❌ Video Init Error: $error");
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }

      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          print("🔄 Retrying Video Initialization...");
          _initializeVideo();
        }
      });
    });
  }

  // ✅ Initialize Chewie (Ensures Fullscreen & Full-Width)
  void _initializeChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: true,
      allowFullScreen: true, // ✅ Enables Full-Screen Mode
      showControls: true, // ✅ Shows Play/Pause/Fullscreen Button
      aspectRatio:
          _videoController.value.aspectRatio, // ✅ Keep correct aspect ratio
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white54,
      ),
    );

    if (mounted) {
      setState(() {}); // ✅ Trigger UI Rebuild After Initializing Chewie
    }
  }

  // ✅ Open Video in Full-Screen
  void _enterFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullScreenVideoPlayer(videoController: _videoController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Center(child: Text("❌ Error Loading Video"));
    }

    if (_chewieController == null) {
      return Center(
          child: CircularProgressIndicator()); // ✅ Show loading spinner
    }

    // return ClipRRect(
    //   borderRadius: BorderRadius.circular(10),
    //   child: Container(
    //     width: double.infinity, // ✅ Full Width
    //     height: 250, // ✅ Adjust height as needed
    //     child: Stack(
    //       children: [
    //         Chewie(controller: _chewieController!), // ✅ Show Video
    //         Positioned(
    //           bottom: 10,
    //           right: 10,
    //           child: IconButton(
    //             icon: Icon(Icons.fullscreen, color: Colors.white, size: 35),
    //             onPressed: _enterFullScreen,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio, // ✅ Keeps video scaled
        child: Stack(
          children: [
            Chewie(controller: _chewieController!),
            Positioned(
              bottom: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.fullscreen, color: Colors.white, size: 35),
                onPressed: _enterFullScreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}

// ✅ Full-Screen Video Player
class FullScreenVideoPlayer extends StatelessWidget {
  final VideoPlayerController videoController;

  const FullScreenVideoPlayer({Key? key, required this.videoController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: videoController.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
