from datetime import datetime, time as dtime, timedelta, timezone

def within_quiet_hours(local_dt: datetime, quiet_hours: str = "21-08") -> bool:
    start_h, end_h = [int(x) for x in quiet_hours.split("-")]
    start = local_dt.replace(hour=start_h, minute=0, second=0, microsecond=0)
    end = local_dt.replace(hour=end_h, minute=0, second=0, microsecond=0)
    if start_h < end_h:
        return start <= local_dt < end
    return local_dt >= start or local_dt < end

def next_allowed_time(local_dt: datetime, quiet_hours: str = "21-08") -> datetime:
    if not within_quiet_hours(local_dt, quiet_hours):
        return local_dt
    # Move to end of quiet hours
    end_h = int(quiet_hours.split("-")[1])
    candidate = local_dt.replace(hour=end_h, minute=5, second=0, microsecond=0)
    if candidate <= local_dt:
        candidate += timedelta(days=1)
    return candidate
