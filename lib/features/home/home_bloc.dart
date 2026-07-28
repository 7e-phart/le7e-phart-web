import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadNews>(_onLoadNews);
    on<LoadEvents>(_onLoadEvents);
  }

  Future<void> _onLoadNews(
    LoadNews event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    // Les données sont maintenant chargées depuis Firebase dans home_page.dart
    // Ce bloc n'est plus utilisé pour le chargement des données
    emit(HomeLoaded(news: [], events: []));
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<HomeState> emit,
  ) async {
    // Les données sont maintenant chargées depuis Firebase dans home_page.dart
    // Ce bloc n'est plus utilisé pour le chargement des données
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(events: []));
    }
  }
}
