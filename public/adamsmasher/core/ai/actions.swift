
public static func GetActionAnimationSlideParams(slideParams: AIActionSlideParams) -> ActionAnimationSlideParams {
  let resultParams: ActionAnimationSlideParams;
  resultParams.distance = slideParams.distance;
  resultParams.directionAngle = slideParams.directionAngle;
  resultParams.finalRotationAngle = 0.00;
  resultParams.offsetToTarget = slideParams.offset;
  resultParams.offsetAroundTarget = 0.00;
  resultParams.slideToTarget = slideParams.slideToTarget;
  resultParams.duration = slideParams.duration;
  resultParams.positionSpeed = 1.00;
  resultParams.rotationSpeed = 180.00;
  resultParams.maxSlidePositionDistance = 3.00;
  resultParams.maxSlideRotationAngle = 90.00;
  resultParams.slideStartDelay = 0.00;
  resultParams.usePositionSlide = true;
  resultParams.useRotationSlide = true;
  resultParams.maxTargetVelocity = 0.00;
  return resultParams;
}

public static func GetActionAnimationSlideParams(slideRecord: ref<AIActionSlideData_Record>) -> ActionAnimationSlideParams {
  let resultParams: ActionAnimationSlideParams;
  resultParams.distance = slideRecord.Distance();
  resultParams.directionAngle = slideRecord.DirectionAngle();
  resultParams.finalRotationAngle = slideRecord.FinalRotationAngle();
  resultParams.offsetToTarget = slideRecord.OffsetToTarget();
  resultParams.offsetAroundTarget = slideRecord.OffsetAroundTarget();
  resultParams.slideToTarget = IsDefined(slideRecord.Target());
  resultParams.duration = slideRecord.Duration();
  resultParams.positionSpeed = slideRecord.PositionSpeed();
  resultParams.rotationSpeed = slideRecord.RotationSpeed();
  resultParams.slideStartDelay = slideRecord.SlideStartDelay();
  resultParams.usePositionSlide = slideRecord.UsePositionSlide();
  resultParams.useRotationSlide = slideRecord.UseRotationSlide();
  resultParams.maxSlidePositionDistance = slideRecord.Distance();
  resultParams.zAlignmentThreshold = slideRecord.ZAlignmentCollisionThreshold();
  resultParams.maxTargetVelocity = 0.00;
  resultParams.maxSlideRotationAngle = 135.00;
  return resultParams;
}
