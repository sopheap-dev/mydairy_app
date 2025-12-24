import 'package:dartz/dartz.dart';
import 'package:mydairy/app/core/utils/errors/failures.dart';
import 'package:mydairy/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);
  Future<Either<Failure, bool>> authenticateBiometric();
  Future<Either<Failure, bool>> authenticatePin(String pin);
  Future<Either<Failure, void>> setPin(String pin);
}
