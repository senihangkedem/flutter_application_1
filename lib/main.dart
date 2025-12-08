// main.dart
// TravelBuddy — All-Combos Immersive Single File
//
// Make sure you added the dependencies shown to pubspec.yaml and configured
// Google Maps API keys for android/ios. Replace sample network resources
// (lottie + audio + images) with your own assets where desired.

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;

// ---------------------- MAIN -----------------------
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TravelBuddyImmersiveApp());
}

class TravelBuddyImmersiveApp extends StatelessWidget {
  const TravelBuddyImmersiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelBuddy Immersive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF3F7F9),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeShell(),
    );
  }
}

// ---------------------- DATA MODELS -----------------------
class Trip {
  final String id;
  final String title;
  final String location;
  final String image; // network or asset path
  final double lat, lng;
  final double rating;
  final String description;

  Trip({
    required this.id,
    required this.title,
    required this.location,
    required this.image,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.description,
  });
}

// Simple demo trips (Nepali favorites)
final List<Trip> demoTrips = [
  Trip(
    id: 't-1',
    title: 'Pokhara Lakeside',
    location: 'Pokhara, Nepal',
    image:
        'https://images.https://unsplash.com/photos/red-and-yellow-boat-on-sea-during-daytime-p37C9uoNq_s.''',
    lat: 28.2096,
    lng: 83.9856,
    rating: 4.8,
    description: 'Peaceful lakes, boating, paragliding and stunning sunsets.',
  ),
  Trip(
    id: 't-2',
    title: 'Annapurna Base Camp',
    location: 'Ghandruk, Nepal',
    image:
        'https://images.https://unsplash.com/photos/a-group-of-people-standing-on-top-of-a-snow-covered-slope-g1E7NWcPw58',
    lat: 28.4168,
    lng: 83.8644,
    rating: 4.9,
    description: 'Iconic trek with dramatic mountain scenery.',
  ),
  Trip(
    id: 't-3',
    title: 'Chitwan Safari',
    location: 'Chitwan, Nepal',
    image:
        'https://images.https://unsplash.com/photos/rhino-and-jeep-on-a-forest-road-J0yySgR8Kok',
    lat: 27.5291,
    lng: 84.3542,
    rating: 4.6,
    description: 'Jungle safaris, rhinos, birdwatching and Tharu culture.',
  ),
];

// ---------------------- HOME SHELL (Bottom Nav & Audio) -----------------------
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  int selectedIndex = 0;
  late final AudioPlayer _ambiencePlayer;
  bool audioPlaying = false;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // Initialize pages (Explore, Destinations, Map, Trips, Settings)
    pages = [
      ExplorePage(onOpenTrip: _openTrip),
      DestinationsGrid(onOpenTrip: _openTrip),
      const AnimatedMapScreen(),
      TripsListPage(onOpenTrip: _openTrip),
      const SettingsPage(),
    ];

    // AUDIO: ambient sound loop (network example). Replace URL with your own ambient mp3 if desired.
    _ambiencePlayer = AudioPlayer(playerId: const Uuid().v4());
    _playAmbient();
  }

  Future<void> _playAmbient() async {
    try {
      // Primary: Try the main Pixabay URL
      const url1 =
          'https://cdn.pixabay.com/download/audio/2022/03/15/audio_8b3a7d5f97.mp3?filename=birds-ambient-11155.mp3';

      await _ambiencePlayer.setReleaseMode(ReleaseMode.loop);

      try {
        // Try primary URL first
        await _ambiencePlayer.play(UrlSource(url1));
        setState(() => audioPlaying = true);
        debugPrint('🎵 Ambient audio playing: Primary URL');
        return;
      } catch (e1) {
        debugPrint('⚠️ Primary URL failed: $e1');

        // Fallback 1: Try alternative Pixabay bird sound
        const url2 =
            'https://pixabay.com/api/download/2088738/?filename=gentle-rain.mp3';
        try {
          await _ambiencePlayer.play(UrlSource(url2));
          setState(() => audioPlaying = true);
          debugPrint('🎵 Ambient audio playing: Fallback URL 1');
          return;
        } catch (e2) {
          debugPrint('⚠️ Fallback URL 1 failed: $e2');

          // Fallback 2: Try another ambient sound source
          const url3 =
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
          try {
            await _ambiencePlayer.play(UrlSource(url3));
            setState(() => audioPlaying = true);
            debugPrint('🎵 Ambient audio playing: Fallback URL 2');
            return;
          } catch (e3) {
            debugPrint(
              '⚠️ Fallback URL 2 failed: $e3 - Audio disabled for this session',
            );
            setState(() => audioPlaying = false);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Ambient audio initialization failed: $e');
      setState(() => audioPlaying = false);
    }
  }

  @override
  void dispose() {
    _ambiencePlayer.stop();
    _ambiencePlayer.dispose();
    super.dispose();
  }

  void _openTrip(Trip trip) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => TripDetailFull(trip: trip),
        transitionsBuilder: (context, animation, secondary, child) {
          // smooth fade + scale
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.98, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extend body to show glass nav overlapping
      extendBody: true,
      body: pages[selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GlassBottomNav(
          currentIndex: selectedIndex,
          onTap: (i) => setState(() => selectedIndex = i),
          audioPlaying: audioPlaying,
          onAudioToggle: () {
            if (audioPlaying) {
              _ambiencePlayer.pause();
            } else {
              _ambiencePlayer.resume();
            }
            setState(() => audioPlaying = !audioPlaying);
          },
        ),
      ),
    );
  }
}

// ---------------------- GLASS + ANIMATED BOTTOM NAV -----------------------
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final bool audioPlaying;
  final VoidCallback onAudioToggle;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.audioPlaying,
    required this.onAudioToggle,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.explore_rounded,
      Icons.location_city_rounded,
      Icons.map_rounded,
      Icons.bookmark_rounded,
      Icons.settings_rounded,
    ];
    final labels = ['Explore', 'Places', 'Map', 'Trips', 'Settings'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < icons.length; i++)
                GestureDetector(
                  onTap: () => onTap(i),
                  child: NavIcon(
                    icon: icons[i],
                    label: labels[i],
                    active: currentIndex == i,
                  ),
                ),

              // Audio toggle (separate button)
              GestureDetector(
                onTap: onAudioToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: audioPlaying
                        ? LinearGradient(
                            colors: [Colors.teal, Colors.blueAccent],
                          )
                        : null,
                    color: audioPlaying ? null : Colors.white.withOpacity(0.06),
                    boxShadow: audioPlaying
                        ? [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.25),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    audioPlaying
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: audioPlaying ? Colors.white : Colors.white70,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const NavIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: active
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Row(
        children: [
          Icon(icon, size: 22, color: active ? Colors.white : Colors.white70),
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: TextStyle(
              color: active ? Colors.white : Colors.white54,
              fontWeight: FontWeight.w600,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

// ---------------------- EXPLORE PAGE (PARALLAX + 3D TILT CARDS + Lottie) -----------------------
class ExplorePage extends StatefulWidget {
  final void Function(Trip) onOpenTrip;
  const ExplorePage({super.key, required this.onOpenTrip});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late PageController _pageController;
  double page = 0.0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82)
      ..addListener(_listener);
  }

  void _listener() {
    setState(() {
      page = _pageController.page ?? 0;
      currentPage = page.round();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_listener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // background hero / lottie banner
    return Stack(
      children: [
        // soft background image
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=1600&q=60',
            fit: BoxFit.cover,
          ),
        ),
        // gentle blur for glass effect
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.35)),
        ),

        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header with Lottie micro-animation
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Discover Nepal',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(6),
                      child: ClipOval(
                        child: Lottie.network(
                          // sample Lottie. Replace with your own if needed.
                          'https://assets10.lottiefiles.com/packages/lf20_h4th9ofg.json',
                          repeat: true,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.travel_explore),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView with parallax & 3D tilt
              SizedBox(
                height: 360,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: demoTrips.length,
                  itemBuilder: (context, index) {
                    final t = demoTrips[index];
                    final delta = (page - index);
                    final isOnScreen = (index - page).abs() <= 1.0;

                    // 3D tilt transform values
                    final rotationY = lerpDouble(0, -0.18, delta.clamp(-1, 1))!;
                    final tilt = delta.clamp(-1.0, 1.0) * 8.0;
                    final scale = (1 - (delta.abs() * 0.08)).clamp(0.88, 1.0);

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(rotationY),
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: isOnScreen ? 1.0 : 0.9,
                        child: GestureDetector(
                          onTap: () => widget.onOpenTrip(t),
                          child: ParallaxCard(
                            trip: t,
                            tilt: tilt,
                            scale: scale,
                            progress: (1 - delta.abs()).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // small page indicator
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(demoTrips.length, (i) {
                    final selected = i == currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: selected ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.tealAccent.shade100
                            : Colors.white30,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 12),

              // quick actions row (glass chips)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GlassActionChip(icon: Icons.hiking, label: 'Trekking'),
                    _GlassActionChip(icon: Icons.flight, label: 'Flights'),
                    _GlassActionChip(icon: Icons.hotel, label: 'Lodging'),
                    _GlassActionChip(icon: Icons.explore, label: 'Guides'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ParallaxCard: background image moves slightly depending on tilt/progress
class ParallaxCard extends StatefulWidget {
  final Trip trip;
  final double tilt;
  final double scale;
  final double progress;

  const ParallaxCard({
    super.key,
    required this.trip,
    required this.tilt,
    required this.scale,
    required this.progress,
  });

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard>
    with SingleTickerProviderStateMixin {
  bool liked = false;
  late final AnimationController _likeController;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => liked = !liked);
    if (liked) {
      _likeController.forward();
    } else {
      _likeController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // parallax offset based on progress
    final parallaxOffset = (1 - widget.progress) * 30;

    return Transform.scale(
      scale: widget.scale,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Stack(
          children: [
            // card container
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 340,
                color: Colors.white.withOpacity(0.06),
                child: Stack(
                  children: [
                    // moving background image (parallax)
                    Positioned.fill(
                      left: -parallaxOffset,
                      right: parallaxOffset,
                      child: Image.network(
                        widget.trip.image,
                        fit: BoxFit.cover,
                        alignment: Alignment(-widget.progress * 0.4, 0),
                        loadingBuilder: (c, w, p) {
                          if (p == null) return w;
                          return Container(color: Colors.grey.shade300);
                        },
                      ),
                    ),

                    // gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.45),
                              Colors.transparent,
                              Colors.black.withOpacity(0.25),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),

                    // inner content (title, rating, like heart)
                    Positioned(
                      left: 18,
                      bottom: 18,
                      right: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Hero(
                                      tag: 'title-${widget.trip.id}',
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Text(
                                          widget.trip.title,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.trip.location,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _toggleLike,
                                child: ScaleTransition(
                                  scale: Tween(begin: 1.0, end: 1.2).animate(
                                    CurvedAnimation(
                                      parent: _likeController,
                                      curve: Curves.elasticOut,
                                    ),
                                  ),
                                  child: Icon(
                                    liked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: liked ? Colors.red : Colors.white70,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _RatingBadge(rating: widget.trip.rating),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.white70,
                                ),
                                onPressed: () {
                                  // default action: open detail (handled by parent onTap)
                                },
                                icon: const Icon(
                                  Icons.map,
                                  color: Colors.black87,
                                ),
                                label: const Text('View'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // floating lottie badge (top-right)
            Positioned(
              top: 12,
              right: 12,
              child: SizedBox(
                width: 62,
                height: 62,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  color: Colors.black.withOpacity(0.18),
                  child: Center(
                    child: Lottie.network(
                      'https://assets9.lottiefiles.com/packages/lf20_sjcp8xff.json',
                      width: 46,
                      height: 46,
                      repeat: true,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// small rating badge
class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// small glass style action chip
class _GlassActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassActionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- DESTINATIONS GRID -----------------------
class DestinationsGrid extends StatelessWidget {
  final void Function(Trip) onOpenTrip;
  const DestinationsGrid({super.key, required this.onOpenTrip});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.86,
        ),
        itemCount: demoTrips.length,
        itemBuilder: (context, i) {
          final t = demoTrips[i];
          return GestureDetector(
            onTap: () => onOpenTrip(t),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(t.image, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------- TRIPS LIST PAGE (simple) -----------------------
class TripsListPage extends StatelessWidget {
  final void Function(Trip) onOpenTrip;
  const TripsListPage({super.key, required this.onOpenTrip});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: demoTrips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final t = demoTrips[i];
          return ListTile(
            tileColor: Colors.white.withOpacity(0.04),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                t.image,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              t.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(t.location),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chevron_right),
                Text(t.rating.toStringAsFixed(1)),
              ],
            ),
            onTap: () => onOpenTrip(t),
          );
        },
      ),
    );
  }
}

// ---------------------- SETTINGS PAGE -----------------------
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile.adaptive(
              value: true,
              onChanged: (v) {},
              title: const Text('Notifications'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Account'),
              subtitle: const Text('Seni Limbu'),
            ),
          ),
          Card(child: ListTile(title: const Text('Terms & Privacy'))),
        ],
      ),
    );
  }
}

// ---------------------- TRIP DETAIL (HERO + LOTTIE + SOUND) -----------------------
class TripDetailFull extends StatefulWidget {
  final Trip trip;
  const TripDetailFull({super.key, required this.trip});

  @override
  State<TripDetailFull> createState() => _TripDetailFullState();
}

class _TripDetailFullState extends State<TripDetailFull>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool liked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => liked = !liked);
    if (liked) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // hero background image (expands from card)
          Positioned.fill(
            child: Hero(
              tag: 'title-${t.id}',
              child: Image.network(t.image, fit: BoxFit.cover),
            ),
          ),
          // dark gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.15),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // top bar with back and lottie
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _CircularIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleLike,
                        child: ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.15).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Lottie.network(
                            liked
                                ? 'https://assets7.lottiefiles.com/packages/lf20_u4yrau.json' // heart pop
                                : 'https://assets10.lottiefiles.com/packages/lf20_pzv2xusw.json', // outline
                            height: 56,
                            width: 56,
                            repeat: false,
                            animate: liked,
                            errorBuilder: (c, e, s) => Icon(
                              Icons.favorite,
                              color: liked ? Colors.red : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // info card
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 380,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t.location,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const Spacer(),
                              _RatingBadge(rating: t.rating),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(t.description),
                          const SizedBox(height: 12),
                          const Text(
                            'Nearby lodging',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 90,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _LodgeCard(
                                  name: 'Lakeside Hotel',
                                  price: 'Rs. 3500/night',
                                  rating: 4.7,
                                ),
                                _LodgeCard(
                                  name: 'Mountain Guesthouse',
                                  price: 'Rs. 1800/night',
                                  rating: 4.4,
                                ),
                                _LodgeCard(
                                  name: 'Eco Lodge',
                                  price: 'Rs. 2400/night',
                                  rating: 4.6,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // open map screen
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => MapScreenInteractive(
                                          lat: t.lat,
                                          lng: t.lng,
                                          title: t.title,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.map),
                                  label: const Text('Open Map'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                ),
                                child: const Text('Book'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// small circular icon button used in detail
class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircularIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white70,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}

// small lodge card
class _LodgeCard extends StatelessWidget {
  final String name, price;
  final double rating;
  const _LodgeCard({
    required this.name,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(price, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 6),
                  Text(rating.toString()),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Book', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------- ANIMATED MAP SCREEN (Pins + Path + Animated Markers) -----------------------
class AnimatedMapScreen extends StatefulWidget {
  const AnimatedMapScreen({super.key});

  @override
  State<AnimatedMapScreen> createState() => _AnimatedMapScreenState();
}

class _AnimatedMapScreenState extends State<AnimatedMapScreen>
    with SingleTickerProviderStateMixin {
  late final Completer<gmf.GoogleMapController> _mapController;
  final Set<gmf.Marker> _markers = {};
  final Set<gmf.Polyline> _polylines = {};
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _mapController = Completer();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Add demo pins (Pokhara, Annapurna, Chitwan)
    _addPin(demoTrips[0]);
    _addPin(demoTrips[1]);
    _addPin(demoTrips[2]);

    // Animated travel path polyline connecting the three
    _polylines.add(
      gmf.Polyline(
        polylineId: const gmf.PolylineId('path'),
        points: demoTrips.map((t) => gmf.LatLng(t.lat, t.lng)).toList(),
        color: Colors.tealAccent,
        width: 4,
      ),
    );
  }

  void _addPin(Trip t) {
    final marker = gmf.Marker(
      markerId: gmf.MarkerId(t.id),
      position: gmf.LatLng(t.lat, t.lng),
      infoWindow: gmf.InfoWindow(title: t.title, snippet: t.location),
      onTap: () {
        // open detail
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => TripDetailFull(trip: t)));
      },
      icon: gmf.BitmapDescriptor.defaultMarkerWithHue(
        gmf.BitmapDescriptor.hueAzure,
      ),
    );
    _markers.add(marker);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = gmf.CameraPosition(
      target: gmf.LatLng(28.0, 84.0),
      zoom: 7.2,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Map')),
      body: Stack(
        children: [
          gmf.GoogleMap(
            initialCameraPosition: camera,
            markers: _markers,
            polylines: _polylines,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _mapController.complete(controller),
          ),

          // animated floating pins legend
          Positioned(
            right: 14,
            top: 14,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (ctx, child) {
                    final s = 1 + (_animController.value * 0.18);
                    return Transform.scale(scale: s, child: child);
                  },
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.white,
                    onPressed: () {},
                    child: const Icon(Icons.place, color: Colors.teal),
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    // zoom to Pokhara
                    final c = await _mapController.future;
                    await c.animateCamera(
                      gmf.CameraUpdate.newLatLngZoom(
                        gmf.LatLng(demoTrips[0].lat, demoTrips[0].lng),
                        13,
                      ),
                    );
                  },
                  child: const Icon(Icons.location_on, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Interactive single-place map for detail open
class MapScreenInteractive extends StatefulWidget {
  final double lat, lng;
  final String title;
  const MapScreenInteractive({
    required this.lat,
    required this.lng,
    required this.title,
    super.key,
  });

  @override
  State<MapScreenInteractive> createState() => _MapScreenInteractiveState();
}

class _MapScreenInteractiveState extends State<MapScreenInteractive> {
  late gmf.GoogleMapController controller;
  late final gmf.Marker marker;

  @override
  void initState() {
    super.initState();
    marker = gmf.Marker(
      markerId: gmf.MarkerId(widget.title),
      position: gmf.LatLng(widget.lat, widget.lng),
      infoWindow: gmf.InfoWindow(title: widget.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final camera = gmf.CameraPosition(
      target: gmf.LatLng(widget.lat, widget.lng),
      zoom: 13,
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: gmf.GoogleMap(
        initialCameraPosition: camera,
        markers: {marker},
        onMapCreated: (c) => controller = c,
      ),
    );
  }
}
