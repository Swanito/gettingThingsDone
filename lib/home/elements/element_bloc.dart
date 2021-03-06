import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gtd/core/models/gtd_element.dart';
import 'package:gtd/core/models/gtd_project.dart';
import 'package:gtd/core/models/gtd_project_entity.dart';
import 'package:gtd/core/repositories/remote/project_repository.dart';
import 'package:gtd/core/repositories/repository.dart';
import 'package:gtd/home/procesar/advanced/advanced_process_form.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'element_state.dart';
part 'element_event.dart';

class ElementBloc extends Bloc<ElementEvent, ElementState> {
  final ElementRepository _elementRepository;

  StreamSubscription _elementSubscription;

  ElementBloc({@required ElementRepository elementRepository})
      : assert(elementRepository != null),
        _elementRepository = elementRepository;

  @override
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
    } else if (event is MoveToDelete) {
      yield* _mapMoveToDeleteToState(event);
    } else if (event is MoveToReference) {
      yield* _mapMoveToReferenceToState(event);
    } else if (event is MoveToWaintingFor) {
      yield* _mapMoveToWaitingForToState(event);
    } else if (event is AddContextToElement) {
      yield* _mapAddContextToElementToState(event);
    } else if (event is Process) {
      yield* _mapProcessToState(event);
    } else if (event is AddDateToElement) {
      yield* _mapAddDateToElement(event);
    } else if (event is AddProjectToElement) {
      yield* _mapAddProjectToElementToState(event);
    } else if(event is RecoverFromTrash) {
      yield* _mapRecoverFromTrashToState(event);
    } else if(event is AddDescriptionToElement) {
      yield* _mapAddDescriptionToElementToState(event);
    } else if(event is AddTitleToElement) {
      yield* _mapAddTitleToElementToState(event);
    } else if(event is AddRecurrencyToElement) {
      yield* _mapAddRecurrencyToElementToState(event);
    } else if(event is AddImageToElement) {
      yield* _mapAddImageToElementToState(event);
    }
  }

  Stream<ElementState> _mapLoadEventsToState() async* {
    await _elementSubscription?.cancel();
    _elementSubscription = await _elementRepository.getElements().then(
          (value) => value.listen((elements) => add(ElementsUpdated(elements))),
        );
  }

  Stream<ElementState> _mapCreateElementToState(CreateElement event) async* {
    await _elementRepository.createElement(event.element);
  }

  Stream<ElementState> _mapDeleteElementToState(DeleteElement event) async* {
    await _elementRepository.deleteElement(event.element);
  }

  Stream<ElementState> _mapUpdateElementToState(UpdateElement event) async* {
    await _elementRepository.updateElement(event.element);
  }

  Stream<ElementState> _mapElementsUpdatedToState(
      ElementsUpdated event) async* {
    yield SucessLoadingElements(event.elements);
  }

  Stream<ElementState> _mapMarkAsCompletedToState(
      MarkAsCompleted event) async* {
    event.element.currentStatus = 'COMPLETED';
    event.element.completedAt = Timestamp.now();
    await _elementRepository.updateElement(event.element);
    await HapticFeedback.mediumImpact();
    yield ElementCompleted(event.element);
  }

  Stream<ElementState> _mapProcessToState(Process event) async* {
    event.elementToBeProcessed.lastStatus = event.elementToBeProcessed.currentStatus;
    event.elementToBeProcessed.currentStatus = 'PROCESSED';
    await _elementRepository.updateElement(event.elementToBeProcessed);
    yield ElementProcessed();
  }

  Stream<ElementState> _mapUnmarkAsCompletedToState(
      UnmarkAsCompleted event) async* {
    event.element.currentStatus = 'PROCESSED';
    event.element.completedAt = null;
    await _elementRepository.updateElement(event.element);
    yield LoadingElements();
  }

  Stream<ElementState> _mapRecoverFromTrashToState(
      RecoverFromTrash event) async* {
    event.element.currentStatus = event.element.lastStatus;
    await _elementRepository.updateElement(event.element);
    yield LoadingElements();
  }

  Stream<ElementState> _mapMoveToDeleteToState(MoveToDelete event) async* {
    event.element.lastStatus = event.element.currentStatus;
    event.element.currentStatus = 'DELETED';
    await _elementRepository.updateElement(event.element);
    yield ElementDeleted();
  }

  Stream<ElementState> _mapMoveToReferenceToState(
      MoveToReference event) async* {
    event.element.currentStatus = 'REFERENCED';
    await _elementRepository.updateElement(event.element);
    yield ElementProcessed();
  }

  Stream<ElementState> _mapMoveToWaitingForToState(
      MoveToWaintingFor event) async* {
    event.element.currentStatus = 'WAITINGFOR';
    event.element.asignee = event.asignee;
    await _elementRepository.updateElement(event.element);
    yield ElementProcessed();
  }

  Stream<ElementState> _mapAddContextToElementToState(
      AddContextToElement event) async* {
    List<String> arrayContexts = event.context.split(',');
    arrayContexts.removeWhere((item) => item == "");
    List<String> arrayWithoutSpaces = [];
    for (var context in arrayContexts) {
      arrayWithoutSpaces.add(context.trim());
    }
    event.elementToBeProcessed.contexts = arrayWithoutSpaces;
    await _elementRepository.updateElement(event.elementToBeProcessed);
  }

  Stream<ElementState> _mapAddDateToElement(AddDateToElement event) async* {
    event.elementToBeProcessed.dueDate = event.date != "" ? event.date : null;
    await _elementRepository.updateElement(event.elementToBeProcessed);
  }

  Stream<ElementState> _mapAddProjectToElementToState(
      AddProjectToElement event) async* {
    ProjectRepository _projectRepository = ProjectRepositoryImpl();
    Project projectToBeAdded;

    if (event.projectTitle != null && event.projectTitle != "") {
    await _projectRepository.getProject(event.projectTitle).then((value) => {
          for (var project in value.documents)
            {
              projectToBeAdded =
                  Project.fromEntity(ProjectEntity.fromSnapshot(project)),
            },
          if (projectToBeAdded == null)
            {
              projectToBeAdded = Project(event.projectTitle),
              _projectRepository.createProject(project: projectToBeAdded)
            }
        });

    }

    event.elementToBeProcessed.project = projectToBeAdded;
    await _elementRepository.updateElement(event.elementToBeProcessed);
  }

  Stream<ElementState> _mapAddDescriptionToElementToState(AddDescriptionToElement event) async* {
    event.elementToBeProcessed.description = event.description != "" ? event.description : null;
    await _elementRepository.updateElement(event.elementToBeProcessed);
  }

  Stream<ElementState> _mapAddTitleToElementToState(AddTitleToElement event) async* {
    event.elementToBeProcessed.summary = event.title != "" ? event.title : null;
    await _elementRepository.updateElement(event.elementToBeProcessed);
  }

Stream<ElementState> _mapAddRecurrencyToElementToState(AddRecurrencyToElement event) async* {
  int timeInterval;
    if(event.period == DatePeriod.WEEK) {
      timeInterval = event.number * 604800; //segundo que tiene una semana * numero de repeticiones 
      event.elementToBeProcessed.period = 'WEEK';
    } 
    if(event.period == DatePeriod.DAY) {
      timeInterval = event.number * 86400; //segundo que tiene un dia * numero de repeticiones 
      event.elementToBeProcessed.period = 'DAY';
    }

    event.elementToBeProcessed.repeatInterval = timeInterval;
    await _elementRepository.updateElement(event.elementToBeProcessed);
  }

  Stream<ElementState> _mapAddImageToElementToState(AddImageToElement event) async* {
    String imageRemotePath;
    if (event.takenImage != null) {
        var uuid = Uuid();
        imageRemotePath = await _elementRepository.uploadFile(event.imageFile, uuid.v4());
    }
    event.element.imageRemotePath = imageRemotePath;
    await _elementRepository.updateElement(event.element);
  }

  @override
  Future<void> close() {
    _elementSubscription?.cancel();
    return super.close();
  }
}
