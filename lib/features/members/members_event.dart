part of 'members_bloc.dart';

abstract class MembersEvent extends Equatable {
  const MembersEvent();

  @override
  List<Object> get props => [];
}

class LoadMembers extends MembersEvent {
  const LoadMembers();
}

class AddMember extends MembersEvent {
  final String name;
  final String firstName;
  final String email;
  final String phone;
  final MembershipType membershipType;

  const AddMember({
    required this.name,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.membershipType,
  });

  @override
  List<Object> get props => [name, firstName, email, phone, membershipType];
}

class UpdateMember extends MembersEvent {
  final Member member;

  const UpdateMember(this.member);

  @override
  List<Object> get props => [member];
}

class DeleteMember extends MembersEvent {
  final String memberId;

  const DeleteMember(this.memberId);

  @override
  List<Object> get props => [memberId];
}
