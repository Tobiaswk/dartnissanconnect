enum LockStatus { CLOSED, LOCKED, OPEN, UNLOCKED, UNKNOWN }

class NissanConnectLockStatus {
  late LockStatus doorFrontLeft;
  late LockStatus doorFrontRight;
  late LockStatus doorRearRight;
  late LockStatus doorRearLeft;
  late LockStatus doorHatch;
  late LockStatus locked;

  NissanConnectLockStatus(Map params) {
    var recs = params['data']['attributes'];

    this.doorFrontLeft = _lockStatus(recs['doorStatusFrontLeft']);
    this.doorFrontRight = _lockStatus(recs['doorStatusFrontRight']);
    this.doorRearRight = _lockStatus(recs['doorStatusRearLeft']);
    this.doorRearLeft = _lockStatus(recs['doorStatusRearRight']);
    this.doorHatch = _lockStatus(recs['hatchStatus']);
    this.locked = _lockStatus(recs['lockStatus']);
  }

  LockStatus _lockStatus(String status) {
    if (status == 'closed') return LockStatus.CLOSED;
    if (status == 'locked') return LockStatus.LOCKED;
    if (status == 'open') return LockStatus.OPEN;
    if (status == 'unlocked') return LockStatus.UNLOCKED;
    return LockStatus.UNKNOWN;
  }
}
