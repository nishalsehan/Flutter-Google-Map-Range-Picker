
import 'package:flutter/material.dart';

class DistanceSlider extends StatelessWidget{

  final int distance;
  final void Function(double)? onChanged;
  final void Function(double)? onChangeEnd;
  const DistanceSlider({super.key, required this.distance, this.onChanged, this.onChangeEnd});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
        width: size.width * 0.9,
        child: Row(
          children: [
            SizedBox(
              width: size.width * 0.75,
              //used theme to changed the slider colors and shapes
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  inactiveTrackColor: Colors.black12,
                  activeTrackColor: Colors.redAccent,
                  thumbColor: Colors.redAccent,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: size.height * 0.01),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                  trackHeight: 2,
                ),
                child: Slider(
                  label: null,// removed the label
                  value: distance.toDouble(),
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                  min: 0,
                  divisions: 20, //there are 20 divisions in the 100km range
                  max: 100,//maximum range is 100km
                ),
              ),
            ),
            SizedBox(
                width: size.width * 0.15,
                child: Text(
                    "$distance Km",
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontSize: size.height * 0.014,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w500,
                    )
                )
            )
          ],
        )
    );
  }

}