import 'package:repository/repository.dart';

// part 'rank.g.dart';

@Requestor(
  'me/rank/@level',
  subRequestors: [
    GET(),
    POST()
  ],
)
abstract class Rank extends HttpRequestor {
  int points;
  int level;
  String title;
  @Field('next_level')
  int nextLevel;
  @Field('next_title')
  String nextTitle;
  @Ignore
  String test;
}