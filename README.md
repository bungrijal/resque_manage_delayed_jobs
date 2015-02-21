# Resque Delayed Jobs Management #

This lib contains some functions to manage resque delayed jobs. Usage example:

To get list of delayed jobs:

```
Resque::Delayed.find_jobs_with_class YourClass
Resque::Delayed.find_jobs_with_args args
Resque::Delayed.find_jobs_with_class_and_args YourClass, args
```

There is #destroy method to remove and #delay method to delay a job:
```
delayed_fetch_jobs = Resque::Delayed.find_jobs_with_class_and_args YourClass, args
job = delayed_fetch_jobs.first
job.delay 1.hour
job.destroy
```

You can also destroy jobs by class or ags:
```
Resque::Delayed.remove_jobs_with_class YourClass
Resque::Delayed.remove_jobs_with_args args
Resque::Delayed.remove_jobs_with_class_and_args YourClass, args
```

And delay jobs by class or args:
```
Resque::Delayed.delay_jobs_with_class 1.hours, YourClass
Resque::Delayed.delay_jobs_with_args 1.minute, args
Resque::Delayed.delay_jobs_with_class_and_args 3.hours, YourClass, args
```