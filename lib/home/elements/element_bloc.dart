import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gtd/core/models/gtd_element.dart';
import 'package:gtd/core/repositories/repository.dart';
import 'package:meta/meta.dart';

part 'element_state.dart';
part 'element_event.dart';

class ElementBloc extends Bloc<ElementEvent, ElementState> {
  final ElementRepository _elementRepository;
  StreamSubscription _elementSubscription;

  ElementBloc({@required ElementRepository elementRepository})
      : assert(elementRepository != null),
        _elementRepository = elementRepository;

  @override
  // TODO: implement initialState
  get initialState => LoadingElements();

  @override
  Stream<ElementState> mapEventToState(ElementEvent event) async* {
    if (event is LoadElements) {
      yield* _mapLoadEventsToState();
    } else if (event is CreateElement) {
      yield* _mapCreateElementToState(event);
    } else if (event is DeleteElement) {
      yield* _mapDeleteElementToState(event);
    } else if (event is UpdateElement) {
      yield* _mapUpdateElementToState(event);
    } else if (event is ElementsUpdated) {
      yield* _mapElementsUpdatedToState(event);
    } else if (event is MarkAsCompleted) {
      yield* _mapMarkAsCompletedToState(event);
    } else if (event is UnmarkAsCompleted) {
      yield* _mapUnmarkAsCompletedToState(event);
    }
  }

  Stream<ElementState> _mapLoadEventsToState() async* {
    _elementSubscription?.cancel();
    _elementSubscription = _elementRepository
        .getElements()
        .listen((elements) => add(ElementsUpdated(elements)));
  }

  Stream<ElementState> _mapCreateElementToState(CreateElement event) async* {
    _elementRepository.createElement(event.element);
  }

  Stream<ElementState> _mapDeleteElementToState(DeleteElement event) async* {
    _elementRepository.deleteElement(event.element);
  }

  Stream<ElementState> _mapUpdateElementToState(UpdateElement event) async* {
    _elementRepository.updateElement(event.element);
  }

  Stream<ElementState> _mapElementsUpdatedToState(
      ElementsUpdated event) async* {
    yield SucessLoadingElements(event.elements);
  }

  Stream<ElementState> _mapMarkAsCompletedToState(MarkAsCompleted event) async* {
    event.element.currentStatus = 'COMPLETED';
    _elementRepository.updateElement(event.element);
    yield LoadingElements();
  }

    Stream<ElementState> _mapUnmarkAsCompletedToState(UnmarkAsCompleted event) async* {
    event.element.currentStatus = 'PROCESSED';
    _elementRepository.updateElement(event.element);
    yield LoadingElements();
  }

  @override
  Future<void> close() {
    _elementSubscription?.cancel();
    return super.close();
  }
}