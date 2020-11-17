/*
 * @Author: lidan6
 * @Date: 2020-10-13 14:41:38
 * @LastEditors: lidan6
 * @LastEditTime: 2020-10-27 15:54:55
 * @Description: 
 */
import 'package:flutter/material.dart';

class ShapeContainer extends ShapeBorder {
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final String arrowDirection;
  final double arrowWidth;
  final double arrowHeight;
  final double arrowDistance;

  ShapeContainer({
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.arrowDirection,
    this.arrowWidth,
    this.arrowHeight,
    this.arrowDistance
  });

  @override
  EdgeInsetsGeometry get dimensions => new EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {
    TextDirection textDirection
  }) {
    return new Path()..fillType = PathFillType.evenOdd..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  //绘制边框
  Path getOuterPath(Rect rect, {
    TextDirection textDirection
  }) {
    double topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius;

    Path _getLeftTopPath(Rect rect) {
      return new Path()..moveTo(rect.left, rect.bottom - bottomLeftRadius)..lineTo(rect.left, rect.top + topLeftRadius)..arcToPoint(Offset(rect.left + topLeftRadius, rect.top), //绘制圆角
        radius: new Radius.circular(topLeftRadius))..lineTo(rect.right - topRightRadius, rect.top)..arcToPoint(Offset(rect.right, rect.top + topRightRadius), //绘制圆角
        radius: new Radius.circular(topRightRadius),
        clockwise: true);
    }

    Path _getBottomRightPath(Rect rect) {
      return new Path()..moveTo(rect.left + bottomLeftRadius, rect.bottom)..lineTo(rect.right - bottomRightRadius, rect.bottom)..arcToPoint(Offset(rect.right, rect.bottom - bottomRightRadius),
        radius: new Radius.circular(bottomRightRadius), clockwise: false)..lineTo(rect.right, rect.top + topRightRadius)..arcToPoint(Offset(rect.right - topRightRadius, rect.top),
        radius: new Radius.circular(topRightRadius), clockwise: false);
    }

    topLeftRadius = borderRadius;
    topRightRadius = borderRadius;
    bottomLeftRadius = borderRadius;
    bottomRightRadius = borderRadius;

    switch (arrowDirection) {
      case "up":
        return _getLeftTopPath(rect)
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),
              radius: new Radius.circular(bottomRightRadius), clockwise: true)
          ..lineTo(rect.left + arrowDistance,rect.bottom)
          ..lineTo(rect.left + arrowDistance + arrowHeight/2,rect.bottom+arrowWidth)
          ..lineTo(rect.left + arrowDistance + arrowHeight,rect.bottom)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),
              radius: new Radius.circular(bottomLeftRadius), clockwise: true)
          ..lineTo(rect.left, rect.top + topLeftRadius)
          ..arcToPoint(Offset(rect.left + topLeftRadius, rect.top),
              radius: new Radius.circular(topLeftRadius), clockwise: true)
          ;
      
      case "down":
        return _getBottomRightPath(rect)
            ..lineTo(rect.right - arrowDistance, rect.top)
            ..lineTo(rect.right - arrowDistance - arrowHeight/2, rect.top - arrowWidth)
            ..lineTo(rect.right - arrowDistance - arrowHeight, rect.top)
            ..lineTo(rect.left + topLeftRadius, rect.top)
            ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),
              radius: new Radius.circular(topLeftRadius), clockwise: false)
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: new Radius.circular(bottomLeftRadius), clockwise: false);

      case "right":
        return _getLeftTopPath(rect)
          ..lineTo(rect.right, rect.top + arrowDistance)
          ..lineTo(rect.right + arrowWidth, rect.top + arrowDistance + arrowHeight / 2)
          ..lineTo(rect.right, rect.top + arrowDistance + arrowHeight)
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),radius: new Radius.circular(bottomRightRadius), clockwise: true)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),radius: new Radius.circular(bottomLeftRadius), clockwise: true);
      case "left":
        return _getBottomRightPath(rect)
          ..lineTo(rect.left + topLeftRadius, rect.top)
          ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),radius: new Radius.circular(topLeftRadius), clockwise: false)
          ..lineTo(rect.left, rect.top + arrowDistance)
          ..lineTo(rect.left - arrowWidth, rect.top + arrowDistance + arrowHeight / 2)
          ..lineTo(rect.left, rect.top + arrowDistance + arrowHeight)
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),radius: new Radius.circular(bottomLeftRadius), clockwise: false);

      default:
        throw AssertionError(arrowDirection);
    }
  }

  @override
  void paint(Canvas canvas, Rect rect, {
    TextDirection textDirection
  }) {
    Paint paint = new Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = borderWidth;

    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return new ShapeContainer(
      borderRadius: this.borderRadius,
      borderColor: this.borderColor,
      borderWidth: this.borderWidth,
      arrowDirection: this.arrowDirection,
      arrowWidth: this.arrowWidth,
      arrowHeight: this.arrowHeight,
      arrowDistance: this.arrowDistance,
    );
  }
}