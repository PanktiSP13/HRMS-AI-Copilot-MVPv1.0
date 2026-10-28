import 'package:json_annotation/json_annotation.dart';
part 'profile.g.dart';


@JsonSerializable()
class ProfileUpdateRequest {
  final String? phone;
  final String? address;

  const ProfileUpdateRequest({
    this.phone,
    this.address,
  });

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json,) => _$ProfileUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUpdateRequestToJson(this);
}