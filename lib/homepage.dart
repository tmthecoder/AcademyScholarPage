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

  ScrollController _scroll = ScrollController();
  late final AnimationController _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000)
  )..repeat(reverse: true);
  late final Animation<Color?> _colorTween = ColorTween(begin: Colors.white, end: Colors.grey)
      .animate(_animationController);
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
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    double offset = _scroll.hasClients ? _scroll.offset : 0;
    _scroll = ScrollController(initialScrollOffset: offset);
    initializeScrollListeners();
  }

  void initializeScrollListeners() {
    _animationControllers["landingOut"] = AnimationController(vsync: this);
    _animationControllers["phone1In"] = AnimationController(vsync: this);
    _animationControllers["text1In"] = AnimationController(vsync: this);
    _animationControllers["phone1Out"] = AnimationController(vsync: this);
    _animationControllers["phone2In"] = AnimationController(vsync: this);
    _animationControllers["phone2Out"] = AnimationController(vsync: this);
    _animationControllers["phone3In"] = AnimationController(vsync: this);
    _animationControllers["phone3Out"] = AnimationController(vsync: this);
    _animationControllers["outroIn"] = AnimationController(vsync: this);
    _animationControllers["outroPhoneIn"] = AnimationController(vsync: this);
    setAnimationValueListener("landingOut", 0.1, 0.6, false);
    setAnimationValueListener("phone1In", 0.2, 0.6, true);
    setAnimationValueListener("text1In", 0.4, 0.6, true);
    setAnimationValueListener("phone1Out", 0.7, 0.8, false);
    setAnimationValueListener("phone2In", 0.8, 0.9, true);
    setAnimationValueListener("phone2Out", 1.0, 1.1, false);
    setAnimationValueListener("phone3In", 1.1, 1.2, true);
    setAnimationValueListener("phone3Out", 1.3, 1.4, false);
    setAnimationValueListener("outroIn", 1.5, 1.6, true);
    setAnimationValueListener("outroPhoneIn", 1.5, 1.7, true);
  }

  void setAnimationValueListener(String mapKey, double startingFrame, double endingFrame, bool forward) {
    void listener() {
      double frameStep = _scroll.position.maxScrollExtent / 2;
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

  Size _getScaledSize(String animKey, Size origSize) {
    if (_animationControllers[animKey] == null) return origSize;
    double value = _animationControllers[animKey]!.value;
    return Size(origSize.width * value, origSize.height * value);
  }


  ///Main widget build method
  ///Builds the UI on this screen
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        createOutro(),
        createPhoneIntro(
          phoneKey: "phone1",
          textKey: "text1",
          headerText: "Seamlessly transfer Text...",
          showSlide: true,
        ),
        createPhoneIntro(
            phoneKey: "phone2",
            headerText: "Images..."
        ),
        createPhoneIntro(
            phoneKey: "phone3",
            headerText: "or Files..."
        ),
        createSlidingTransition(
            child: createScaleTransition(
                child: landingColumn(), mapKey: "landingOut"),
            direction: 3*pi/2,
            distance: 1,
            mapKey: "landingOut"
        ),
        ListView(
          controller: _scroll,
          children: [
            Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 4)),
          ],
        ),
      ],
    );
  }

  Widget createTopBar() => SliverAppBar(
    iconTheme: Theme.of(context).iconTheme,
    centerTitle: false,
    floating: true,
    title: const Text("cClip"),
    actions: [
      const Padding(padding: EdgeInsets.all(10)),
      IconButton(
          icon: Icon(ThemeController.of(context).isDark ? Icons.wb_sunny : Icons.brightness_3), onPressed: () {
        ThemeController.of(context).toggleDark();
      })
    ],
  );

  Widget landingColumn() {
    String theme = ThemeController.of(context).isDark ? "dark" : "light";
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(10)),
        Expanded(
          flex: 20,
          child: Stack(
            children: [
              Center(child: Image.asset("assets/landing_images/$theme/intro_screen.png")),
            ],
          ),
        ),
        Expanded(
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
        Expanded(child: Container(),)
      ],
    );
  }

  Widget createPhoneIntro({
    required String phoneKey,
    required String headerText,
    String? textKey,
    bool showSlide = false,
  }) {
    Widget text = Text(headerText,
        style: Theme.of(context).textTheme.headline5
            ?.merge(const TextStyle(fontWeight: FontWeight.bold))
    );
    String theme = ThemeController.of(context).isDark ? "dark" : "light";
    Widget image = Image.asset("assets/landing_images/$theme/$phoneKey.png",
      height: MediaQuery.of(context).size.height * .7,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        createAnimatedFade(
          child: createAnimatedFade(
              child: showSlide ? createSlidingTransition(
                  child: text,
                  direction: pi,
                  distance: 3,
                  mapKey: "${phoneKey}In"
              ) : text, mapKey: "${phoneKey}Out",
          ), mapKey: "${textKey ?? phoneKey}In",
        ),
        const Padding(padding: EdgeInsets.all(10)),
        Flexible(child: createAnimatedFade(
          child: showSlide ? createSlidingTransition(
            child: createScaleTransition(
              child: image,
              mapKey: "${phoneKey}In"
            ),
            direction: 0,
            distance: 5,
            mapKey: "${phoneKey}In"
          ): createAnimatedFade(child: image, mapKey: "${phoneKey}In"),
          mapKey: "${phoneKey}Out"
        ))
      ],
    );
  }

  Widget createOutro() {
    String theme = ThemeController.of(context).isDark ? "dark" : "light";
    return createAnimatedFade(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Between ALL of your devices!",
              style: Theme.of(context).textTheme.headline5
              ?.merge(const TextStyle(fontWeight: FontWeight.bold))
          ),
          const Padding(padding: EdgeInsets.all(15)),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.all(20)),
                Flexible(child: createSlidingTransition(
                  child: Image.asset("assets/landing_images/$theme/outro_left.png"),
                  direction: 0,
                  distance: 1.3,
                  mapKey: "outroPhoneIn",
                )),
                const Padding(padding: EdgeInsets.all(15)),
                Flexible(
                  flex: 3,
                  child: Image.asset("assets/landing_images/$theme/outro_middle.png")
                ),
                const Padding(padding: EdgeInsets.all(15)),
                Flexible(child: createSlidingTransition(
                  child: Image.asset("assets/landing_images/$theme/outro_right.png"),
                  direction: pi,
                  distance: 1.3,
                  mapKey: "outroPhoneIn",
                )),
                const Padding(padding: EdgeInsets.all(20)),
              ],
            )
          ),
          const Padding(padding: EdgeInsets.all(20)),
        ],
      ), mapKey: "outroIn"
    );
  }

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

}
