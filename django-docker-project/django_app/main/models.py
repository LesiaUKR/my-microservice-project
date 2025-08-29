from django.db import models


# Example model to test database connectivity
class HealthCheck(models.Model):
    timestamp = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, default='OK')
    
    def __str__(self):
        return f"Health check at {self.timestamp}"
    
    class Meta:
        ordering = ['-timestamp']