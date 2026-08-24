import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readora/design_system/tokens/readora_colors.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';

/// A book cover drawn as an object, not a thumbnail.
///
/// The artboards give every cover a tight spine edge on the left, a rounder
/// fore-edge on the right, and an inset shadow down the spine. That small piece
/// of skeuomorphism is what makes the library read as a shelf.
///
/// A meaningful share of Indian and self-published editions have no cover art in
/// either metadata source, so the placeholder is a first-class state, not an
/// afterthought: the title set in the display serif on a muted spine colour,
/// chosen deterministically from the title so the same book always looks the
/// same.
class BookCover extends StatelessWidget {
  const BookCover({
    required this.title,
    this.author,
    this.coverUrl,
    this.width = 64,
    this.aspectRatio = 2 / 3,
    super.key,
  });

  final String title;
  final String? author;
  final String? coverUrl;
  final double width;
  final double aspectRatio;

  double get _height => width / aspectRatio;

  @override
  Widget build(BuildContext context) {
    final hasCover = coverUrl != null && coverUrl!.isNotEmpty;

    return Semantics(
      label: author == null ? title : '$title by $author',
      image: true,
      child: ExcludeSemantics(
        child: Container(
          width: width,
          height: _height,
          decoration: BoxDecoration(
            borderRadius: Radii.coverRadius,
            boxShadow: context.shadow,
          ),
          child: ClipRRect(
            borderRadius: Radii.coverRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasCover)
                  CachedNetworkImage(
                    imageUrl: coverUrl!,
                    fit: BoxFit.cover,
                    fadeInDuration: Motion.fast,
                    placeholder: (_, __) =>
                        _Spine(title: title, author: author, width: width, muted: true),
                    errorWidget: (_, __, ___) =>
                        _Spine(title: title, author: author, width: width),
                  )
                else
                  _Spine(title: title, author: author, width: width),

                // The spine: a soft inset shade down the binding edge. Present
                // on real cover art too, which is what sells the object.
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: width * 0.07,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ReadoraColors.coverSpineShade,
                          ReadoraColors.coverSpineShadeFade,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Spine extends StatelessWidget {
  const _Spine({
    required this.title,
    required this.width,
    this.author,
    this.muted = false,
  });

  final String title;
  final String? author;
  final double width;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final tint = ReadoraColors
        .coverTints[title.hashCode.abs() % ReadoraColors.coverTints.length];

    if (muted) return ColoredBox(color: tint.withValues(alpha: 0.16));

    // Below roughly 48pt there is no room for legible text; the bare spine
    // colour reads better than four clipped characters.
    final showText = width >= 48;

    return Container(
      color: tint,
      padding: EdgeInsets.fromLTRB(
        width * 0.18,
        width * 0.13,
        width * 0.11,
        width * 0.11,
      ),
      child: !showText
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ReadoraType.displayFamily,
                      fontSize: width * 0.16,
                      height: 1.2,
                      color: ReadoraColors.coverInk,
                    ),
                  ),
                ),
                if (author != null)
                  Text(
                    author!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ReadoraType.bodyFamily,
                      fontSize: width * 0.08,
                      letterSpacing: width * 0.08 * 0.18,
                      color: ReadoraColors.coverInk.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
    );
  }
}
