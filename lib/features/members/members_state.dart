part of 'members_bloc.dart';

abstract class MembersState extends Equatable {
  const MembersState();

  @override
  List<Object> get props => [];
}

class MembersInitial extends MembersState {
  const MembersInitial();
}

class MembersLoading extends MembersState {
  const MembersLoading();
}

class MembersLoaded extends MembersState {
  final List<Member> members;

  const MembersLoaded({required this.members});

  MembersLoaded copyWith({List<Member>? members}) {
    return MembersLoaded(members: members ?? this.members);
  }

  @override
  List<Object> get props => [members];
}

class MembersError extends MembersState {
  final String message;

  const MembersError({required this.message});

  @override
  List<Object> get props => [message];
}
