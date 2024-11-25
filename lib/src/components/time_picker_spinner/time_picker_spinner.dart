import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/omni_datetime_picker_bloc.dart';
import 'bloc/time_picker_spinner_bloc.dart';

class TimePickerSpinner extends StatefulWidget {
  final String amText;
  final String pmText;
  final bool isShowSeconds;
  final bool is24HourMode;
  final int minutesInterval;
  final int secondsInterval;
  final bool isForce2Digits;

  final double height;
  final double diameterRatio;
  final double itemExtent;
  final double squeeze;
  final double magnification;
  final bool looping;
  final Widget selectionOverlay;

  const TimePickerSpinner({
    super.key,
    this.height = 200,
    this.diameterRatio = 2,
    this.itemExtent = 40,
    this.squeeze = 1,
    this.magnification = 1.1,
    this.looping = false,
    this.selectionOverlay = const CupertinoPickerDefaultSelectionOverlay(),
    required this.amText,
    required this.pmText,
    required this.isShowSeconds,
    required this.is24HourMode,
    required this.minutesInterval,
    required this.secondsInterval,
    required this.isForce2Digits,
  });

  @override
  _TimePickerSpinnerState createState() => _TimePickerSpinnerState();
}

class _TimePickerSpinnerState extends State<TimePickerSpinner> {
  late OmniDatetimePickerBloc datetimeBloc;

  @override
  void initState() {
    super.initState();
    datetimeBloc = context.read<OmniDatetimePickerBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimePickerSpinnerBloc(
        amText: widget.amText,
        pmText: widget.pmText,
        isShowSeconds: widget.isShowSeconds,
        is24HourMode: widget.is24HourMode,
        minutesInterval: widget.minutesInterval,
        secondsInterval: widget.secondsInterval,
        isForce2Digits: widget.isForce2Digits,
        firstDateTime: datetimeBloc.state.firstDate,
        lastDateTime: datetimeBloc.state.lastDate,
        initialDateTime: datetimeBloc.state.dateTime,
      ),
      child: BlocConsumer<TimePickerSpinnerBloc, TimePickerSpinnerState>(
        listenWhen: (previous, current) {
          if (previous is TimePickerSpinnerInitial &&
              current is TimePickerSpinnerLoaded) {
            return true;
          }

          return false;
        },
        listener: (context, state) {
          if (state is TimePickerSpinnerLoaded) {
            datetimeBloc.add(UpdateMinute(
                minute: int.parse(state.minutes[state.initialMinuteIndex])));

            datetimeBloc.add(UpdateSecond(
                second: int.parse(state.seconds[state.initialSecondIndex])));
          }
        },
        builder: (context, state) {
          if (state is TimePickerSpinnerLoaded) {
            return SizedBox(
              height: widget.height,
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  /// Hours
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: state.initialHourIndex,
                      ),
                      diameterRatio: widget.diameterRatio,
                      itemExtent: widget.itemExtent,
                      squeeze: widget.squeeze,
                      magnification: widget.magnification,
                      looping: widget.looping,
                      selectionOverlay: widget.selectionOverlay,
                      onSelectedItemChanged: (index) {
                        if (!widget.is24HourMode) {
                          final hourOffset =
                              state.abbreviationController.selectedItem == 1
                                  ? 12
                                  : 0;

                          datetimeBloc.add(UpdateHour(
                              hour:
                                  int.parse(state.hours[index]) + hourOffset));
                        } else {
                          datetimeBloc.add(
                              UpdateHour(hour: int.parse(state.hours[index])));
                        }
                      },
                      children: List.generate(
                        growable: false,
                        state.hours.length,
                        (index) {
                          String hour = state.hours[index];

                          if (widget.isForce2Digits) {
                            hour = hour.padLeft(2, '0');
                          }

                          return Center(child: Text(hour));
                        },
                      ),
                    ),
                  ),

                  /// Minutes
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: state.initialMinuteIndex,
                      ),
                      diameterRatio: widget.diameterRatio,
                      itemExtent: widget.itemExtent,
                      squeeze: widget.squeeze,
                      magnification: widget.magnification,
                      looping: widget.looping,
                      selectionOverlay: widget.selectionOverlay,
                      onSelectedItemChanged: (index) {
                        datetimeBloc.add(UpdateMinute(
                            minute: int.parse(state.minutes[index])));
                      },
                      children: List.generate(
                        state.minutes.length,
                        (index) {
                          String minute = state.minutes[index];

                          if (widget.isForce2Digits) {
                            minute = minute.padLeft(2, '0');
                          }
                          return Center(child: Text(minute));
                        },
                      ),
                    ),
                  ),

                  /// Seconds
                  if (widget.isShowSeconds)
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: state.initialSecondIndex,
                        ),
                        diameterRatio: widget.diameterRatio,
                        itemExtent: widget.itemExtent,
                        squeeze: widget.squeeze,
                        magnification: widget.magnification,
                        looping: widget.looping,
                        selectionOverlay: widget.selectionOverlay,
                        onSelectedItemChanged: (index) {
                          datetimeBloc.add(UpdateSecond(
                              second: int.parse(state.seconds[index])));
                        },
                        children: List.generate(
                          state.seconds.length,
                          (index) {
                            String second = state.seconds[index];

                            if (widget.isForce2Digits) {
                              second = second.padLeft(2, '0');
                            }

                            return Center(child: Text(second));
                          },
                        ),
                      ),
                    ),

                  /// AM/PM
                  if (!widget.is24HourMode)
                    Expanded(
                      child: CupertinoPicker.builder(
                        scrollController: state.abbreviationController,
                        diameterRatio: widget.diameterRatio,
                        itemExtent: widget.itemExtent,
                        squeeze: widget.squeeze,
                        magnification: widget.magnification,
                        selectionOverlay: widget.selectionOverlay,
                        onSelectedItemChanged: (index) {
                          if (index == 0) {
                            datetimeBloc
                                .add(const UpdateAbbreviation(isPm: false));
                          } else {
                            datetimeBloc
                                .add(const UpdateAbbreviation(isPm: true));
                          }
                        },
                        childCount: state.abbreviations.length,
                        itemBuilder: (context, index) {
                          return Center(
                              child: Text(state.abbreviations[index]));
                        },
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
