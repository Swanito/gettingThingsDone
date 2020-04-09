part of 'local_state_bloc.dart';

enum GTDLevel {
  Low,
  High
}

abstract class LocalStatusEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object> get props => [];
  
}

class CheckIfGTDLevelIsKnwon extends LocalStatusEvent {}

class SetGTDLevel extends LocalStatusEvent {
  final GTDLevel level;

  SetGTDLevel({@required this.level});

    @override
  List<Object> get props => [level];

  @override
  String toString() => 'Event SetGTDLevel: { GTDLevel: $level }';
}

class CheckIfOnboardingIsCompleted extends LocalStatusEvent {

}

class CompleteOnboardingAction extends LocalStatusEvent {

}

class Logout extends LocalStatusEvent {}