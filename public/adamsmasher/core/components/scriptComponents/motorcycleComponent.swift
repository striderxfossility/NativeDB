
public class MotorcycleComponent extends VehicleComponent {

  protected cb func OnVehicleParkedEvent(evt: ref<VehicleParkedEvent>) -> Bool {
    if evt.park {
      this.ParkBike();
    } else {
      this.UnParkBike();
    };
  }

  protected cb func OnMountingEvent(evt: ref<MountingEvent>) -> Bool {
    super.OnMountingEvent(evt);
    this.GetVehicle().PhysicsWakeUp();
    this.UnParkBike();
    this.PickUpBike();
  }

  protected cb func OnUnmountingEvent(evt: ref<UnmountingEvent>) -> Bool {
    let currentSpeed: Float;
    let knockOverBike: ref<KnockOverBikeEvent>;
    super.OnUnmountingEvent(evt);
    currentSpeed = this.GetVehicle().GetCurrentSpeed();
    if currentSpeed >= 3.00 {
      knockOverBike = new KnockOverBikeEvent();
      this.GetVehicle().QueueEvent(knockOverBike);
    } else {
      this.ParkBike();
    };
  }

  private final func ParkBike() -> Void {
    let currentTiltAngle: Float = (this.GetVehicle() as BikeObject).GetCustomTargetTilt();
    let record: wref<Vehicle_Record> = this.GetVehicle().GetRecord();
    let vehicleDataPackage: wref<VehicleDataPackage_Record> = record.VehDataPackage();
    let desiredTiltAngle: Float = vehicleDataPackage.ParkingAngle();
    if !(this.GetVehicle() as BikeObject).IsTiltControlEnabled() {
      return;
    };
    if currentTiltAngle == 0.00 && !VehicleComponent.IsVehicleOccupied(this.GetVehicle().GetGame(), this.GetVehicle()) {
      (this.GetVehicle() as BikeObject).SetCustomTargetTilt(desiredTiltAngle);
      AnimationControllerComponent.PushEvent(this.GetVehicle(), n"toPark");
      AnimationControllerComponent.PushEvent(this.GetVehicle(), n"readyModeEnd");
      this.GetVehicle().PhysicsWakeUp();
    };
  }

  private final func UnParkBike() -> Void {
    (this.GetVehicle() as BikeObject).SetCustomTargetTilt(0.00);
    AnimationControllerComponent.PushEvent(this.GetVehicle(), n"unPark");
  }

  private final func PickUpBike() -> Void {
    if !(this.GetVehicle() as BikeObject).IsTiltControlEnabled() {
      (this.GetVehicle() as BikeObject).EnableTiltControl(true);
    };
  }

  protected cb func OnKnockOverBikeEvent(evt: ref<KnockOverBikeEvent>) -> Bool {
    let bikeImpulseEvent: ref<PhysicalImpulseEvent>;
    let tempVec4: Vector4;
    if evt.forceKnockdown {
      if (this.GetVehicle() as BikeObject).IsTiltControlEnabled() {
        this.UnParkBike();
        (this.GetVehicle() as BikeObject).EnableTiltControl(false);
      };
    } else {
      if !VehicleComponent.IsVehicleOccupied(this.GetVehicle().GetGame(), this.GetVehicle()) {
        if (this.GetVehicle() as BikeObject).IsTiltControlEnabled() {
          this.UnParkBike();
          (this.GetVehicle() as BikeObject).EnableTiltControl(false);
        };
      };
    };
    if evt.applyDirectionalForce {
      bikeImpulseEvent = new PhysicalImpulseEvent();
      bikeImpulseEvent.radius = 1.00;
      tempVec4 = this.GetVehicle().GetWorldPosition();
      bikeImpulseEvent.worldPosition.X = tempVec4.X;
      bikeImpulseEvent.worldPosition.Y = tempVec4.Y;
      bikeImpulseEvent.worldPosition.Z = tempVec4.Z + 0.50;
      tempVec4 = WorldTransform.GetRight(this.GetVehicle().GetWorldTransform());
      tempVec4 *= this.GetVehicle().GetTotalMass() * 3.80;
      bikeImpulseEvent.worldImpulse = Vector4.Vector4To3(tempVec4);
      this.GetVehicle().QueueEvent(bikeImpulseEvent);
    };
  }
}
