import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/course.dart';
import 'services/pyq_data_service.dart';
import 'widgets/contribute_footer.dart';
import 'widgets/course_card.dart';
import 'widgets/course_list_tile.dart';
import 'widgets/paper_button.dart';
import 'widgets/shimmer_loading.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    required this.themeMode,
    required this.onThemeToggle,
    required this.onAccentColorChange,
    required this.currentAccentColor,
  });

  final String title;
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;
  final Function(Color) onAccentColorChange;
  final Color currentAccentColor;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Course> courses = [];
  List<Course> filteredCourses = [];
  final PyqDataService pyqDataService = PyqDataService();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool filterMidSem = false;
  bool filterEndSem = false;
  String? selectedYear;
  final Set<String> selectedTypes = {};
  bool isGridView = true;
  bool isLoading = true;
  bool isStreamComplete = false;
  double loadingProgress = 0.0;
  int totalCourses = 0;
  int loadedCourses = 0;
  String? errorMessage;
  final Set<int> _expandedCourseNums = {};
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  String _getCategoryName(String courseId) {
    final id = courseId.toUpperCase();
    if (id.startsWith('CSET')) return 'CS CORE';
    if (id.startsWith('EMAT')) return 'MATH & FOUNDATIONS';
    if (id.startsWith('EPHY')) return 'PHYSICS & SCIENCES';
    if (id.startsWith('UVAC')) return 'VALUE ADDED COURSES';
    return 'GENERAL';
  }

  Color _getCategoryAccentColor(String category) {
    switch (category) {
      case 'CS CORE': return Colors.blue;
      case 'MATH & FOUNDATIONS': return Colors.orange;
      case 'PHYSICS & SCIENCES': return Colors.teal;
      case 'VALUE ADDED COURSES': return Colors.green;
      default: return Colors.indigo;
    }
  }

  void _toggleCourseExpanded(int courseNum) {
    setState(() {
      if (!_expandedCourseNums.remove(courseNum)) {
        _expandedCourseNums.add(courseNum);
      }
    });
  }

  void _showColorPicker() {
    final colorOptions = <(String, Color)>[
      ('Deep Purple', Colors.deepPurple),
      ('Indigo', Colors.indigo),
      ('Ocean Blue', Colors.blue),
      ('Teal', Colors.teal),
      ('Cyan', Colors.cyan),
      ('Forest Green', Colors.green),
      ('Lime', Colors.lime.shade700),
      ('Amber', Colors.amber),
      ('Coral', Colors.deepOrange),
      ('Red', Colors.red),
      ('Rose', Colors.pink),
      ('Maroon', const Color(0xFF880E4F)),
      ('Slate', Colors.blueGrey),
      ('Brown', Colors.brown),
      ('M3 Violet', const Color(0xFF6750A4)),
      ('Sky', const Color(0xFF2196F3)),
      ('Fuchsia', const Color(0xFFE91E63)),
      ('Gold', const Color(0xFFFFB300)),
      ('Mint', const Color(0xFF00BFA5)),
      ('Lavender', const Color(0xFF7C4DFF)),
    ];

    Color previewColor = widget.currentAccentColor;
    final hexController = TextEditingController(
      text: previewColor.toARGB32().toRadixString(16).substring(2).toUpperCase(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DefaultTabController(
        length: 2,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            void updateColor(Color c) {
              setSheetState(() {
                previewColor = c;
                hexController.text =
                    c.toARGB32().toRadixString(16).substring(2).toUpperCase();
                hexController.selection = TextSelection.fromPosition(
                  TextPosition(offset: hexController.text.length),
                );
              });
            }

            final previewName = colorOptions
                .where((e) => e.$2.toARGB32() == previewColor.toARGB32())
                .map((e) => e.$1)
                .firstOrNull ?? 'Custom';

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Center(
                        child: Container(
                          width: 36, height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accent Color',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Any color in the universe — yours to pick.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Live preview strip
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  previewColor,
                                  previewColor.withValues(alpha: 0.55),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: previewColor.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  previewName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '#${previewColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                    // Tabs
                    TabBar(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      tabs: const [
                        Tab(text: 'Swatches'),
                        Tab(text: 'Color Wheel'),
                      ],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                    ),
                    Flexible(
                      child: TabBarView(
                        children: [
                          // ── Tab 1: Swatches ──────────────────────────────
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.82,
                              ),
                              itemCount: colorOptions.length,
                              itemBuilder: (context, index) {
                                final (name, color) = colorOptions[index];
                                final isSelected =
                                    previewColor.toARGB32() == color.toARGB32();
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    updateColor(color);
                                  },
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        width: isSelected ? 50 : 44,
                                        height: isSelected ? 50 : 44,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.white, width: 3)
                                              : Border.all(
                                                  color: Colors.transparent,
                                                  width: 3),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: color.withValues(
                                                        alpha: 0.5),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  )
                                                ]
                                              : [],
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check,
                                                color: Colors.white, size: 20)
                                            : null,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? color
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // ── Tab 2: Color Wheel ───────────────────────────
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                            child: Column(
                              children: [
                                // HSV color wheel from flutter_colorpicker
                                ColorPicker(
                                  pickerColor: previewColor,
                                  onColorChanged: (c) => updateColor(c),
                                  colorPickerWidth: double.infinity,
                                  pickerAreaHeightPercent: 0.5,
                                  enableAlpha: false,
                                  hexInputBar: false,
                                  labelTypes: const [],
                                  displayThumbColor: true,
                                  paletteType: PaletteType.hsvWithHue,
                                ),
                                const SizedBox(height: 12),
                                // Hex input
                                Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: previewColor,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: previewColor.withValues(alpha: 0.4),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: hexController,
                                        maxLength: 6,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        decoration: InputDecoration(
                                          prefixText: '#',
                                          labelText: 'Hex Code',
                                          counterText: '',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 12),
                                        ),
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                        onChanged: (val) {
                                          if (val.length == 6) {
                                            try {
                                              final c = Color(
                                                  int.parse('FF$val', radix: 16));
                                              setSheetState(
                                                  () => previewColor = c);
                                            } catch (_) {}
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Apply / Cancel buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: previewColor.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: FilledButton(
                                onPressed: () {
                                  widget.onAccentColorChange(previewColor);
                                  Navigator.pop(context);
                                },
                                style: FilledButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  backgroundColor: previewColor,
                                ),
                                child: const Text('Apply Color',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 400;
      if (show != _showScrollToTop) setState(() => _showScrollToTop = show);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCourses();
    });
  }

  Future<void> _loadCourses() async {
    setState(() {
      isLoading = true;
      isStreamComplete = false;
      loadingProgress = 0.0;
      loadedCourses = 0;
      courses.clear();
      filteredCourses.clear();
      errorMessage = null;
    });

    try {
      await for (final course in pyqDataService.fetchCoursesStream()) {
        setState(() {
          courses.add(course);
          loadedCourses++;
          if (searchQuery.isEmpty) {
            filteredCourses = List.from(courses);
          } else {
            filterDocuments(searchQuery);
          }
        });
      }

      setState(() {
        isStreamComplete = true;
        isLoading = false;
        loadingProgress = 1.0;
        totalCourses = courses.length;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load courses: ${e.toString()}';
        isLoading = false;
        isStreamComplete = true;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void filterDocuments(String query) {
    setState(() {
      searchQuery = query;

      if (query.isNotEmpty) {
        _expandedCourseNums.clear();
      }

      final queryWords =
          query
              .toLowerCase()
              .split(' ')
              .where((word) => word.isNotEmpty)
              .toList();

      filteredCourses =
          courses.where((course) {
            bool matchesFilters = true;

            if (filterMidSem || filterEndSem) {
              bool hasMidSem = false;
              bool hasEndSem = false;

              for (final paper in course.papers) {
                final lowerLabel = paper.label.toLowerCase();
                if (lowerLabel.contains('mid semester')) hasMidSem = true;
                if (lowerLabel.contains('end semester')) hasEndSem = true;
              }

              if (filterMidSem && filterEndSem) {
                matchesFilters = hasMidSem || hasEndSem;
              } else if (filterMidSem) {
                matchesFilters = hasMidSem;
              } else if (filterEndSem) {
                matchesFilters = hasEndSem;
              }
            }

            if (selectedYear != null) {
              bool hasYear = false;
              for (final paper in course.papers) {
                if (paper.paperSuffix.contains(selectedYear!.substring(0, 4)) ||
                    paper.paperSuffix == selectedYear) {
                  hasYear = true;
                  break;
                }
              }
              if (!hasYear) matchesFilters = false;
            }

            if (selectedTypes.isNotEmpty) {
              bool hasType = false;
              for (final paper in course.papers) {
                final lower = paper.label.toLowerCase();
                for (final type in selectedTypes) {
                  if (lower.contains(type.toLowerCase())) {
                    hasType = true;
                    break;
                  }
                }
                if (hasType) break;
              }
              if (!hasType) matchesFilters = false;
            }

            if (!matchesFilters) return false;

            if (query.isEmpty) return true;

            final courseName = course.name.toLowerCase();
            final courseCodes = course.courseId
                .map((id) => id.toLowerCase())
                .join(' ');
            final description =
                '$courseName ${course.joinedCourseIds.toLowerCase()}';

            bool matchesAllWords = true;
            for (final word in queryWords) {
              if (!courseName.contains(word) &&
                  !courseCodes.contains(word) &&
                  !description.contains(word)) {
                matchesAllWords = false;
                break;
              }
            }

            final lowerQuery = query.toLowerCase();
            final exactPhraseMatch =
                courseName.contains(lowerQuery) ||
                courseCodes.contains(lowerQuery) ||
                description.contains(lowerQuery);

            return matchesAllWords || exactPhraseMatch;
          }).toList();
    });
  }

  Widget _buildCoursesView(BuildContext context) {
    if (filteredCourses.isEmpty && isStreamComplete) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glow ring icon container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.find_in_page_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No matches for "$searchQuery"',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try refiltering or searching a different term. Reset everything to see all available papers!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                          filterMidSem = false;
                          filterEndSem = false;
                          selectedYear = null;
                          selectedTypes.clear();
                          filterDocuments('');
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reset Everything'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final Map<String, List<Course>> groupedCourses = {};
    final List<String> categoriesOrder = [
      'CS CORE',
      'MATH & FOUNDATIONS',
      'PHYSICS & SCIENCES',
      'VALUE ADDED COURSES',
      'GENERAL',
    ];

    for (var course in filteredCourses) {
      final cat = _getCategoryName(course.primaryCourseId);
      groupedCourses.putIfAbsent(cat, () => []).add(course);
    }

    final activeCategories =
        categoriesOrder
            .where((cat) => groupedCourses.containsKey(cat))
            .toList();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: activeCategories.length + 1,
      itemBuilder: (context, catIndex) {
        if (catIndex == activeCategories.length) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ContributeFooterCard(),
          );
        }

        final category = activeCategories[catIndex];
        final categoryCourses = groupedCourses[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getCategoryAccentColor(category),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: _getCategoryAccentColor(category),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getCategoryAccentColor(category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${categoryCourses.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryAccentColor(category),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isGridView)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: screenWidth >= 480
                    ? GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: screenWidth >= 1200
                            ? 4
                            : (screenWidth >= 700 ? 3 : 2),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: screenWidth >= 1200
                            ? 1.2
                            : (screenWidth >= 700 ? 1.0 : 0.72),
                        children: [
                          for (final course in categoryCourses)
                            TweenAnimationBuilder<double>(
                              key: ValueKey(course.courseNum),
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 12 * (1.0 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: CourseCard(course: course),
                            ),
                        ],
                      )
                    : Column(
                        children: [
                          for (final course in categoryCourses) ...[
                            TweenAnimationBuilder<double>(
                              key: ValueKey(course.courseNum),
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 12 * (1.0 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: CourseCard(course: course),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < categoryCourses.length; i++) ...[
                    (() {
                      final isExpanded = _expandedCourseNums.contains(categoryCourses[i].courseNum);
                      // Global index for stagger: sum of all items before this category + i
                      final globalIdx = activeCategories
                          .take(catIndex)
                          .fold(0, (sum, c) => sum + (groupedCourses[c]?.length ?? 0)) + i;
                      return _StaggeredItem(
                        key: ValueKey('stagger_${categoryCourses[i].courseNum}'),
                        index: globalIdx,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: isExpanded ? 8 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                                : Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isExpanded
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                                  : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                              width: isExpanded ? 1.5 : 1.0,
                            ),
                            boxShadow: isExpanded
                                ? [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              CourseListTile(
                                course: categoryCourses[i],
                                isExpanded: isExpanded,
                                onTap: () => _toggleCourseExpanded(categoryCourses[i].courseNum),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastOutSlowIn,
                                alignment: Alignment.topCenter,
                                child: isExpanded
                                    ? Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: categoryCourses[i].papers
                                              .map(
                                                (paper) => PaperButton(
                                                  label: paper.label,
                                                  url: PyqDataService.paperUrl(paper),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      )
                                    : const SizedBox(width: double.infinity, height: 0),
                              ),
                            ],
                          ),
                        ),
                      );
                    }()),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final activeFiltersCount = (selectedYear != null ? 1 : 0) + selectedTypes.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BU Scholar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Previous Year Papers',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1.5,
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Accent Color',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showColorPicker,
          ),
          IconButton(
            tooltip: 'Contribute papers',
            icon: const Icon(Icons.handshake_outlined),
            onPressed: () async {
              await launchUrl(
                Uri.parse(contributionsUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          screenWidth >= 600
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextButton.icon(
                    onPressed: () async {
                      await launchUrl(Uri.parse("https://github.com/M4dhav"));
                    },
                    icon: SvgPicture.asset(
                      'assets/github-mark.svg',
                      width: 18,
                      height: 18,
                    ),
                    label: const Text(
                      'Made with ❤️ by M4dhav',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  tooltip: 'Made by M4dhav',
                  icon: SvgPicture.asset(
                    'assets/github-mark.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () async {
                    await launchUrl(Uri.parse("https://github.com/M4dhav"));
                  },
                ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for courses...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (screenWidth >= 360)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (searchQuery.isEmpty &&
                                      !filterMidSem &&
                                      !filterEndSem &&
                                      selectedYear == null &&
                                      selectedTypes.isEmpty)
                                  ? '${courses.length} courses'
                                  : '${filteredCourses.length} / ${courses.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        if (searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              filterDocuments('');
                            },
                          )
                        else
                          const SizedBox(width: 8),
                      ],
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                  onChanged: filterDocuments,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ActionChip(
                              avatar: activeFiltersCount > 0
                                  ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$activeFiltersCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.tune, size: 16),
                              label: Text(
                                activeFiltersCount > 0 ? 'Filters ($activeFiltersCount)' : 'Filters',
                                style: TextStyle(
                                  fontWeight: activeFiltersCount > 0 ? FontWeight.bold : null,
                                ),
                              ),
                              onPressed: () => _showFilterSheet(context),
                              backgroundColor: activeFiltersCount > 0
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Mid Semester'),
                              selected: filterMidSem,
                              onSelected: (selected) {
                                setState(() {
                                  filterMidSem = selected;
                                  filterDocuments(searchQuery);
                                });
                              },
                              selectedColor: Colors.purple.withValues(
                                alpha: 0.15,
                              ),
                              checkmarkColor: Colors.purple.shade800,
                              labelStyle: TextStyle(
                                color:
                                    filterMidSem
                                        ? Colors.purple.shade800
                                        : null,
                                fontWeight:
                                    filterMidSem ? FontWeight.w600 : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('End Semester'),
                              selected: filterEndSem,
                              onSelected: (selected) {
                                setState(() {
                                  filterEndSem = selected;
                                  filterDocuments(searchQuery);
                                });
                              },
                              selectedColor: Colors.green.withValues(
                                alpha: 0.15,
                              ),
                              checkmarkColor: Colors.green.shade800,
                              labelStyle: TextStyle(
                                color:
                                    filterEndSem ? Colors.green.shade800 : null,
                                fontWeight:
                                    filterEndSem ? FontWeight.w600 : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            for (final year in ['2024-25', '2022-23'])
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(year),
                                  selected: selectedYear == year,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedYear = selected ? year : null;
                                      filterDocuments(searchQuery);
                                    });
                                  },
                                  selectedColor: Colors.blue.withValues(
                                    alpha: 0.15,
                                  ),
                                  checkmarkColor: Colors.blue.shade800,
                                  labelStyle: TextStyle(
                                    color:
                                        selectedYear == year
                                            ? Colors.blue.shade800
                                            : null,
                                    fontWeight:
                                        selectedYear == year
                                            ? FontWeight.w600
                                            : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: Icon(
                        isGridView ? Icons.view_list : Icons.grid_view,
                      ),
                      onPressed: () => setState(() => isGridView = !isGridView),
                      tooltip:
                          isGridView
                              ? 'Switch to List View'
                              : 'Switch to Grid View',
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: widget.onThemeToggle,
                      tooltip: 'Toggle Theme',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [

                 Expanded(
                  child:
                      errorMessage != null
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error Loading Courses',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Text(
                                    errorMessage!,
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _loadCourses();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                          : isLoading && !isStreamComplete
                          ? ShimmerLoading(isGridView: isGridView)
                          : courses.isEmpty && isStreamComplete
                          ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No Courses Available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No course materials have been uploaded yet.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                          : _buildCoursesView(context),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        scale: _showScrollToTop ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _showScrollToTop ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton.small(
            onPressed: () {
              HapticFeedback.lightImpact();
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            },
            tooltip: 'Scroll to top',
            elevation: 3,
            child: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag indicator handle
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Detailed Filters',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                filterMidSem = false;
                                filterEndSem = false;
                                selectedYear = null;
                                selectedTypes.clear();
                                filterDocuments(searchController.text);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Academic Year',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            ['2025-26', '2024-25', '2023-24', '2022-23'].map((
                              year,
                            ) {
                              final isSelected = selectedYear == year;
                              return ChoiceChip(
                                label: Text(year),
                                selected: isSelected,
                                onSelected: (val) {
                                  setState(() {
                                    selectedYear = val ? year : null;
                                    filterDocuments(searchController.text);
                                  });
                                  setSheetState(() {});
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Paper Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            [
                              'Assignment',
                              'Lab',
                              'Quiz',
                              'Supplementary',
                              'Makeup',
                              'Notes',
                            ].map((type) {
                              final isSelected = selectedTypes.contains(type);
                              return FilterChip(
                                label: Text(type),
                                selected: isSelected,
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      selectedTypes.add(type);
                                    } else {
                                      selectedTypes.remove(type);
                                    }
                                    filterDocuments(searchController.text);
                                  });
                                  setSheetState(() {});
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// A widget that slides and fades in after a staggered delay based on [index].
class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _StaggeredItem({super.key, required this.child, required this.index});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(-0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Staggered delay: cap at 400ms so the last item still feels snappy
    final delay = Duration(milliseconds: (widget.index * 38).clamp(0, 400));
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _opacity, child: widget.child),
    );
  }
}
