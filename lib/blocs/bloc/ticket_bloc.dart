import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'ticket_event.dart';
part 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  TicketBloc() : super(TicketInitial()) {
    on<TicketEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
