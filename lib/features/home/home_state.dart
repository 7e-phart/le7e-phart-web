part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<dynamic> news;
  final List<dynamic> events;

  const HomeLoaded({
    required this.news,
    required this.events,
  });

  HomeLoaded copyWith({
    List<dynamic>? news,
    List<dynamic>? events,
  }) {
    return HomeLoaded(
      news: news ?? this.news,
      events: events ?? this.events,
    );
  }

  @override
  List<Object> get props => [news, events];
}
