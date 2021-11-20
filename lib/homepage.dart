import 'dart:math';

import 'package:controller_widgets/controller_widgets.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {

  const Homepage({Key? key}) : super(key: key);
  ///CreateState method
  ///Sets the state of the app (rebuilt each time a UI change is needed)
  @override
  State<StatefulWidget> createState() {
    return HomepageState();
  }
}

class HomepageState extends State<Homepage>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  // Main scroll controller
  ScrollController _scroll = ScrollController();

  bool _autoScroll = false;

  // Intro Arrow Animation
  late final AnimationController _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000)
  )..repeat(reverse: true);
  late final Animation<Color?> _colorTween = ColorTween(begin: Colors.white, end: Colors.grey)
      .animate(_animationController);

  // Fab Animation
  late final AnimationController _fabController = AnimationController(vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _fabAnimation = Tween<double>(begin: 0, end: 1)
      .animate(_fabController);

  // Fab Animation
  late AnimationController _autoScroller = AnimationController(vsync: this,
    duration: const Duration(milliseconds: 55000),
  );

  // All scrolling animations
  final Map<String, AnimationController> _animationControllers = {};

  ///InitState method
  ///Currently only sets a listener for any light/dark theme changes
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  ///Dispose method
  ///Currently only removes the observer set in initState for the light/dark theme changes
  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _animationController.dispose();
    for (var element in _animationControllers.values) {
      element.dispose();
    }
    _autoScroller.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    double offset = _scroll.hasClients ? _scroll.offset : 0;
    _scroll = ScrollController(initialScrollOffset: offset);
    initializeScrollListeners();
    _autoScroller = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 55000),
      upperBound: MediaQuery.of(context).size.height * 7,
    );
    _autoScroller.addListener(() {
      if (!_autoScroll) return;
      _scroll.jumpTo(_autoScroller.value);
    });
  }

  void initializeScrollListeners() {
    _animationControllers["introOut"] = AnimationController(vsync: this);
    _animationControllers["introPhoneOut"] = AnimationController(vsync: this);
    _animationControllers["achievementIn"] = AnimationController(vsync: this);
    _animationControllers["achievementLeft"] = AnimationController(vsync: this);
    _animationControllers["achievementRight"] = AnimationController(vsync: this);
    _animationControllers["achievementMid"] = AnimationController(vsync: this);
    _animationControllers["achievementOut"] = AnimationController(vsync: this);
    // _animationControllers["landingOut"] = AnimationController(vsync: this);
    // _animationControllers["phone1In"] = AnimationController(vsync: this);
    // _animationControllers["text1In"] = AnimationController(vsync: this);
    // _animationControllers["phone1Out"] = AnimationController(vsync: this);
    // _animationControllers["phone2In"] = AnimationController(vsync: this);
    // _animationControllers["phone2Out"] = AnimationController(vsync: this);
    // _animationControllers["phone3In"] = AnimationController(vsync: this);
    // _animationControllers["phone3Out"] = AnimationController(vsync: this);

    setAnimationValueListener("introOut", 0.5, 0.7, false);
    setAnimationValueListener("introPhoneOut", 0.5, 0.7, false);
    setAnimationValueListener("achievementIn", 0.7, 0.8, true);
    setAnimationValueListener("achievementLeft", 0.8, 0.95, true);
    setAnimationValueListener("achievementRight", 1.1, 1.25, true);
    setAnimationValueListener("achievementMid", 1.4, 1.55, true);
    setAnimationValueListener("achievementOut", 1.7, 1.8, false);
    // setAnimationValueListener("landingOut", 0.1, 0.6, false);
    // setAnimationValueListener("phone1In", 0.2, 0.6, true);
    // setAnimationValueListener("text1In", 0.4, 0.6, true);
    // setAnimationValueListener("phone1Out", 0.7, 0.8, false);
    // setAnimationValueListener("phone2In", 0.8, 0.9, true);
    // setAnimationValueListener("phone2Out", 1.0, 1.1, false);
    // setAnimationValueListener("phone3In", 1.1, 1.2, true);
    // setAnimationValueListener("phone3Out", 1.3, 1.4, false);
  }

  void setAnimationValueListener(String mapKey, double startingFrame, double endingFrame, bool forward) {
    void listener() {
      double frameStep = _scroll.position.maxScrollExtent / 6;
      double entryStart = startingFrame * frameStep;
      double entryEnd = endingFrame * frameStep;
      double position = ((_scroll.offset-entryStart)/(entryEnd-entryStart));
      double posVal = position.clamp(0, 1);
      if (!forward) posVal = 1 - posVal;
      _animationControllers[mapKey]?.value = posVal;
      if (endingFrame == startingFrame) _animationControllers[mapKey]!.value = 1;
    }
    _scroll.addListener(listener);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      listener();
    });
  }

  ///didChangePlatformBrightness method
  ///Only changes the listener's state to the theme allowing to change the theme while user is on the screen
  @override
  void didChangePlatformBrightness() {
    WidgetsBinding.instance?.window.platformBrightness;
  }

  // Size _getScaledSize(String animKey, Size origSize) {
  //   if (_animationControllers[animKey] == null) return origSize;
  //   double value = _animationControllers[animKey]!.value;
  //   return Size(origSize.width * value, origSize.height * value);
  // }


  ///Main widget build method
  ///Builds the UI on this screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          createAnimatedFade(
            mapKey: "achievementOut",
            child: createAchievementSlide()
          ),
          createSlidingTransition(
              child: createScaleTransition(
                  child: createIntro(), mapKey: "introOut"),
              direction: 3*pi/2,
              distance: 1,
              mapKey: "introOut"
          ),
          ListView(
            controller: _scroll,
            children: [
              Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 7)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fabPressed,
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _fabAnimation,
        ),
      ),
    );
  }


  Widget createIntro() {
    return createAnimatedFade(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("5 Reasons Why - Academy Scholar",
              style: Theme.of(context).textTheme.headline5
              ?.merge(const TextStyle(fontWeight: FontWeight.bold))
          ),
          const Padding(padding: EdgeInsets.all(5)),
          Text("Programmed & Presented by Tejas Mehta",
              style: Theme.of(context).textTheme.bodyText2
          ),
          const Padding(padding: EdgeInsets.all(15)),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.all(20)),
                Flexible(child: createSlidingTransition(
                  child: Image.asset("assets/intro/left.png"),
                  direction: pi,
                  distance: 7,
                  mapKey: "introPhoneOut",
                )),
                const Padding(padding: EdgeInsets.all(15)),
                Flexible(
                  flex: 3,
                  child: Image.asset("assets/intro/middle.png")
                ),
                const Padding(padding: EdgeInsets.all(15)),
                Flexible(child: createSlidingTransition(
                  child: Image.asset("assets/intro/right.png"),
                  direction: 0,
                  distance: 7,
                  mapKey: "introPhoneOut",
                )),
                const Padding(padding: EdgeInsets.all(20)),
              ],
            ),
            flex: 10,
          ),
          const Padding(padding: EdgeInsets.all(20)),
          Flexible(
            child: AnimatedBuilder(
                animation: _colorTween,
                builder: (context, _) =>
                    LayoutBuilder(builder: (context, constraint) =>
                        Icon(Icons.keyboard_arrow_down,
                          size: constraint.biggest.height,
                          color: _colorTween.value,
                        ),
                    )
            ),
          ),
        ],
      ), mapKey: "introOut"
    );
  }

  Widget createAchievementSlide() {
    return createAnimatedFade(
      mapKey: "achievementIn",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          createSlidingTransition(
            direction: pi,
            distance: 3,
            mapKey: "achievementLeft",
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: openSourceColumn(),
            ),
          ),
          const VerticalDivider(thickness: 2,),
          middleBlogColumn(),
          const VerticalDivider(thickness: 2,),
          createSlidingTransition(
            direction: 0,
            distance: 3,
            mapKey: "achievementRight",
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: consumerAppColumn(),
            ),
          ),
        ],
      ),
    );
  }

  Widget openSourceColumn() => Column(
    children: [
      Text("Six Open-Source Packages",
        style: Theme.of(context).textTheme.headline6
            ?.merge(const TextStyle(fontWeight: FontWeight.bold)),
      ),
      const Padding(padding: EdgeInsets.all(10)),
      Image.asset("assets/achievement/dargon2.png",
        width: MediaQuery.of(context).size.width * .25,
      ),
      const Padding(padding: EdgeInsets.all(10)),
      Image.asset("assets/achievement/argon2swift.png",
        width: MediaQuery.of(context).size.width * .25,
      ),
      const Padding(padding: EdgeInsets.all(10)),
      Image.asset("assets/achievement/webrtc.png",
        width: MediaQuery.of(context).size.width * .25,
      ),
      const Padding(padding: EdgeInsets.all(10)),
      Image.asset("assets/achievement/odometrycore.png",
        width: MediaQuery.of(context).size.width * .25,
      )
    ],
  );

  Widget consumerAppColumn() => Column(
    children: [
      Text("Two Published Applications",
        style: Theme.of(context).textTheme.headline6
            ?.merge(const TextStyle(fontWeight: FontWeight.bold)),
      ),
      const Spacer(flex: 1),
      clippedImage(Image.asset("assets/achievement/cclip.png",
        width: MediaQuery.of(context).size.width * .05,
      )),
      const Padding(padding: EdgeInsets.all(10)),
      Image.asset("assets/achievement/cclip_listing.png",
        width: MediaQuery.of(context).size.width * .25,
      ),
      const Spacer(flex: 3),
      clippedImage(Image.asset("assets/achievement/scoutscore.png",
        width: MediaQuery.of(context).size.width * .05,
      )),
      const Padding(padding: EdgeInsets.all(10)),
      Image.asset("assets/achievement/scoutscore_listing.png",
        width: MediaQuery.of(context).size.width * .25,
      ),
      const Spacer(flex: 1),
    ],
  );

  Widget middleBlogColumn() => Column(
    children: [
      const Spacer(flex: 2),
      Text("1. Achievement",
        style: Theme.of(context).textTheme.headline3
            ?.merge(const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
        ))
      ),
      const Spacer(flex: 3),
      createSlidingTransition(
        direction: pi/2,
        distance: 3,
        mapKey: "achievementMid",
        child: blogPost(),
      ),
      const Spacer()
    ],
  );

  Widget blogPost() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text("Article Co-Written with Cloudflare",
        style: Theme.of(context).textTheme.headline6
            ?.merge(const TextStyle(fontWeight: FontWeight.bold)),
      ),
      const Padding(padding: EdgeInsets.all(10)),
      Image.asset("assets/achievement/blogpost.png",
        width: MediaQuery.of(context).size.width * .25,
      ),
    ]
  );

  Widget clippedImage(Image img) => ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: img,
  );

  Widget createSlidingTransition({
    required Widget child,
    required double direction,
    required double distance,
    required String mapKey
  }) {
    Animation<Offset> getPosition() {
      return Tween<Offset>(
        begin: Offset.fromDirection(direction, distance),
        end: Offset.zero,
      ).animate(CurvedAnimation(
          parent: _animationControllers[mapKey]!,
          curve: const Interval(0, 1)
      ));
    }
    return SlideTransition(
      position: getPosition(),
      child: child,
    );
  }

  Widget createScaleTransition({
    required Widget child,
    required String mapKey
  }) {
    return ScaleTransition(
      scale: _animationControllers[mapKey]!,
      child: child,
    );
  }

  Widget createAnimatedFade({required Widget child, required String mapKey}) {
    return AnimatedBuilder(
        animation: _animationControllers[mapKey]!,
        builder: (context, _) => IgnorePointer(
          ignoring: _animationControllers[mapKey]!.value < 0.5,
          child: Opacity(
              opacity: _animationControllers[mapKey]!.value,
            child: child,
          ),
        )
    );
  }

  void fabPressed() {
    if (_fabAnimation.value > 0.8) {
      // Pause Pressed
      _fabController.reverse();
      _autoScroll = false;
      _autoScroller.stop();
    } else {
      // Play Pressed
      _fabController.forward();
      _autoScroll = true;
      _autoScroller.value = _scroll.offset;
      _autoScroller.forward();
    }
  }

}
