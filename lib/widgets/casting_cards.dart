import 'package:films_application/models/models.dart';
import 'package:films_application/providers/movie_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class CastingCards extends StatelessWidget {
  final int movieId;
  const CastingCards({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);
    return FutureBuilder(
        builder: ((_, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 180,
              child: CupertinoActivityIndicator(),
            );
          }
          final cast = snapshot.data!;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 30),
            height: 180,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cast.length,
                itemBuilder: (_, int index) =>
                    _CastCard(castData: cast[index])),
          );
        }),
        future: moviesProvider.getMoviesCast(movieId));
  }
}

class _CastCard extends StatelessWidget {
  final Cast castData;
  const _CastCard({super.key, required this.castData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FadeInImage(
            placeholder: const AssetImage('assets/no-image.jpg'),
            image: NetworkImage(castData.fullprofilePath),
            height: 140,
            width: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          castData.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        )
      ]),
    );
  }
}
