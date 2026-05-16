import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/course.dart';
import 'services/pyq_data_service.dart';
import 'widgets/course_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Course> courses = [];
  List<Course> filteredCourses = [];
  final PyqDataService pyqDataService = PyqDataService();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isLoading = true;
  bool isStreamComplete = false;
  double loadingProgress = 0.0;
  int totalCourses = 0;
  int loadedCourses = 0;
  String? errorMessage;
  final Set<int> _expandedCourseNums = {};

  void _toggleCourseExpanded(int courseNum) {
    setState(() {
      if (!_expandedCourseNums.remove(courseNum)) {
        _expandedCourseNums.add(courseNum);
      }
    });
  }

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  void filterDocuments(String query) {
    setState(() {
      searchQuery = query;

      if (query.isNotEmpty) {
        _expandedCourseNums.clear();
      }

      if (query.isEmpty) {
        filteredCourses = List.from(courses);
        return;
      }

      final queryWords = query
          .toLowerCase()
          .split(' ')
          .where((word) => word.isNotEmpty)
          .toList();

      filteredCourses = courses.where((course) {
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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No matches for "$searchQuery"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different course name or code',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  searchController.clear();
                  filterDocuments('');
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear search'),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final useGrid = screenWidth >= 900;

    if (useGrid) {
      const crossAxisCount = 3;
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: StaggeredGrid.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            for (final course in filteredCourses)
              StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: CourseCard(
                  course: course,
                  isExpanded: _expandedCourseNums.contains(course.courseNum),
                  onToggleExpand: () => _toggleCourseExpanded(course.courseNum),
                ),
              ),
          ],
        ),
      );
    } else {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filteredCourses.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final course = filteredCourses[index];
          return CourseCard(
            course: course,
            isExpanded: _expandedCourseNums.contains(course.courseNum),
            onToggleExpand: () => _toggleCourseExpanded(course.courseNum),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BU Scholar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              'Previous Year Papers',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton.icon(
              onPressed: () async {
                await launchUrl(Uri.parse("https://github.com/M4dhav"));
              },
              icon: SvgPicture.asset(
                'assets/github-mark.svg',
                width: 24,
                height: 24,
              ),
              label: const Text(
                'Made with ❤️ by M4dhav',
                style: TextStyle(fontSize: 14),
              ),
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onSurface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for courses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        searchQuery.isEmpty
                            ? '${courses.length} courses'
                            : '${filteredCourses.length} / ${courses.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
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
                      const SizedBox(width: 12),
                  ],
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
              onChanged: filterDocuments,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (isLoading && !isStreamComplete)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(value: null),
                        const SizedBox(height: 8),
                        Text(
                          'Loading courses... ($loadedCourses loaded)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: errorMessage != null
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
                                  style: Theme.of(context).textTheme.bodyMedium,
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
    );
  }
}
