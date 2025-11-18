import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  final Animation<Color?> animation;

  const SkeletonLoader({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 4, // Number of skeleton placeholders
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Row(
                      children: [
                        Container(
                          height: 120,
                          width: 70,
                          color: animation.value,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 20,
                                width: double.infinity,
                                color: animation.value,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 10,
                                width: double.infinity,
                                color: animation.value,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 20,
                                width: double.infinity,
                                color: animation.value,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Container(
                              height: 20,
                              width: 70,
                              color: animation.value,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 30,
                              width: 70,
                              color: animation.value,
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonLoaderView extends StatelessWidget {
  final Animation<Color?> animation;

  const SkeletonLoaderView({Key? key, required this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 1, // Show 3 skeletons as placeholders
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: animation.value,
                    );
                  },
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 40,
                      width: double.infinity,
                      color: animation.value,
                    );
                  },
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 20,
                      width: 200,
                      color: animation.value,
                    );
                  },
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 10,
                      width: 150,
                      color: animation.value,
                    );
                  },
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 20,
                      width: 200,
                      color: animation.value,
                    );
                  },
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 10,
                      width: 150,
                      color: animation.value,
                    );
                  },
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 20,
                      width: 200,
                      color: animation.value,
                    );
                  },
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 10,
                      width: 150,
                      color: animation.value,
                    );
                  },
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 20,
                      width: 200,
                      color: animation.value,
                    );
                  },
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      height: 10,
                      width: 150,
                      color: animation.value,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
