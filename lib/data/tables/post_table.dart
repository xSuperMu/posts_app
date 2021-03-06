import 'package:hive_flutter/hive_flutter.dart';
import 'package:posts_app/data/models/post_model.dart';
import 'package:posts_app/domain/entities/post_entity.dart';

part 'post_table.g.dart';

@HiveType(typeId: 0)
class PostTable extends PostEntity {
  @HiveField(0)
  final int? tId;
  @HiveField(1)
  final String tTitle;
  @HiveField(2)
  final String tBody;

  const PostTable({
    required this.tId,
    required this.tTitle,
    required this.tBody,
  }) : super(
          id: tId,
          title: tTitle,
          body: tBody,
        );

  factory PostTable.fromModel(PostModel post) {
    return PostTable(
      tId: post.id,
      tTitle: post.title,
      tBody: post.body,
    );
  }

  factory PostTable.fromJson(Map<String, dynamic> json) {
    return PostTable(
      tId: json['id'],
      tTitle: json['title'],
      tBody: json['body'],
    );
  }
}
