part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadNews extends HomeEvent {
  const LoadNews();
}

class LoadEvents extends HomeEvent {
  const LoadEvents();
}
