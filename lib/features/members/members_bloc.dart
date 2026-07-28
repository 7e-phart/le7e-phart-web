import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'members_event.dart';
part 'members_state.dart';

class MembersBloc extends Bloc<MembersEvent, MembersState> {
  MembersBloc() : super(MembersInitial()) {
    on<LoadMembers>(_onLoadMembers);
    on<AddMember>(_onAddMember);
    on<UpdateMember>(_onUpdateMember);
    on<DeleteMember>(_onDeleteMember);
  }

  Future<void> _onLoadMembers(
    LoadMembers event,
    Emitter<MembersState> emit,
  ) async {
    emit(MembersLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final members = [
      Member(
        id: '1',
        name: 'Jean Dupont',
        firstName: 'Jean',
        email: 'jean.dupont@email.com',
        phone: '06 12 34 56 78',
        membershipType: MembershipType.supported,
        membershipDate: DateTime(2025, 1, 15),
        isActive: true,
      ),
      Member(
        id: '2',
        name: 'Marie Martin',
        firstName: 'Marie',
        email: 'marie.martin@email.com',
        phone: '06 98 76 54 32',
        membershipType: MembershipType.family,
        membershipDate: DateTime(2025, 3, 20),
        isActive: true,
      ),
      Member(
        id: '3',
        name: 'Pierre Durand',
        firstName: 'Pierre',
        email: 'pierre.durand@email.com',
        phone: '06 11 22 33 44',
        membershipType: MembershipType.simple,
        membershipDate: DateTime(2024, 11, 10),
        isActive: false,
      ),
    ];

    emit(MembersLoaded(members: members));
  }

  Future<void> _onAddMember(
    AddMember event,
    Emitter<MembersState> emit,
  ) async {
    if (state is MembersLoaded) {
      final currentState = state as MembersLoaded;
      final newMember = Member(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        firstName: event.firstName,
        email: event.email,
        phone: event.phone,
        membershipType: event.membershipType,
        membershipDate: DateTime.now(),
        isActive: true,
      );
      emit(currentState.copyWith(
        members: [...currentState.members, newMember],
      ));
    }
  }

  Future<void> _onUpdateMember(
    UpdateMember event,
    Emitter<MembersState> emit,
  ) async {
    if (state is MembersLoaded) {
      final currentState = state as MembersLoaded;
      final updatedMembers = currentState.members.map((member) {
        if (member.id == event.member.id) {
          return event.member;
        }
        return member;
      }).toList();
      emit(currentState.copyWith(members: updatedMembers));
    }
  }

  Future<void> _onDeleteMember(
    DeleteMember event,
    Emitter<MembersState> emit,
  ) async {
    if (state is MembersLoaded) {
      final currentState = state as MembersLoaded;
      final updatedMembers = currentState.members
          .where((member) => member.id != event.memberId)
          .toList();
      emit(currentState.copyWith(members: updatedMembers));
    }
  }
}

enum MembershipType { simple, supported, family }

class Member {
  final String id;
  final String name;
  final String firstName;
  final String email;
  final String phone;
  final MembershipType membershipType;
  final DateTime membershipDate;
  final bool isActive;

  Member({
    required this.id,
    required this.name,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.membershipType,
    required this.membershipDate,
    required this.isActive,
  });

  Member copyWith({
    String? id,
    String? name,
    String? firstName,
    String? email,
    String? phone,
    MembershipType? membershipType,
    DateTime? membershipDate,
    bool? isActive,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      membershipType: membershipType ?? this.membershipType,
      membershipDate: membershipDate ?? this.membershipDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
