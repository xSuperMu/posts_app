import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:posts_app/core/error/exceptions.dart';
import 'package:posts_app/core/error/failures.dart';
import 'package:posts_app/core/network/network_info.dart';
import 'package:posts_app/data/data_sources/local_data_source.dart';
import 'package:posts_app/data/data_sources/remote_data_source.dart';
import 'package:posts_app/data/models/post_model.dart';
import 'package:posts_app/domain/entities/post_entity.dart';
import 'package:posts_app/domain/repositories/posts_repository.dart';

typedef ContactServer = Future<void> Function();

class PostsRepositoryImpl implements PostsRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const PostsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final remotePosts = await remoteDataSource.getPosts();
        await localDataSource.cachePosts(remotePosts);
        return Right(remotePosts);
      } on DioError catch (e) {
        return Left(Failure(FailureType.api, e.message));
      } catch (e) {
        return Left(Failure(FailureType.unknown, e.toString()));
      }
    } else {
      try {
        final localPosts = await localDataSource.getCachedPosts();
        return Right(localPosts);
      } on EmptyCacheException catch (e) {
        return Left(Failure(FailureType.emptyCache, e.message));
      } catch (e) {
        return Left(Failure(FailureType.unknown, e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> createPost(PostEntity post) async {
    final postModel = PostModel.fromEntity(post);

    return await _catchExceptions(() => remoteDataSource.createPost(postModel));
  }

  @override
  Future<Either<Failure, Unit>> updatePost(PostEntity post) async {
    final postModel = PostModel.fromEntity(post);

    return await _catchExceptions(() => remoteDataSource.updatePost(postModel));
  }

  @override
  Future<Either<Failure, Unit>> deletePost(int postId) async {
    return await _catchExceptions(() => remoteDataSource.deletePost(postId));
  }

  Future<Either<Failure, Unit>> _catchExceptions(
      ContactServer contactServer) async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        await contactServer();
        return const Right(unit);
      } on DioError catch (e) {
        return Left(Failure(FailureType.api, e.message));
      } catch (e) {
        return Left(Failure(FailureType.unknown, e.toString()));
      }
    } else {
      return Left(
          Failure(FailureType.network, FailureType.network.message));
    }
  }
}
