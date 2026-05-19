# Email Setup and Configuration

This document covers email configuration for both local development and production environments.

## Overview

**Email backend**: Django's email system with Celery for async delivery

**Local Development**: Mailpit (catches all emails, no external delivery)
**Production**: AWS SES via django-anymail (actual email delivery)

## Local Development (Mailpit)

Mailpit is an email testing tool that captures all outgoing emails without sending them. Perfect for development and testing.

### Configuration

**Service**: `mailpit` container in docker-compose
**SMTP**: `mailpit:1025` (captured, not sent)
**Web UI**: <http://localhost:8025> (view all sent emails)

**Environment variables** (`.envs/.local/.django`):

```env
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=mailpit
EMAIL_PORT=1025
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=
EMAIL_USE_TLS=False
```

### Usage

1. **Start services**:

   ```bash
   docker compose up
   ```

2. **Trigger email** (e.g., register user, send OTP):

   ```python
   from django.core.mail import send_mail

   send_mail(
       'Test Subject',
       'Test message body',
       'noreply@example.com',
       ['recipient@example.com'],
   )
   ```

3. **View email in Mailpit UI**:
   - Open <http://localhost:8025>
   - See all captured emails with HTML and plain text versions
   - View headers, attachments, and raw email source

### Testing Emails

Mailpit captures emails sent by:

- User registration (OTP verification emails)
- Login with unverified email (OTP emails)
- Password reset requests
- Any `send_mail()` or Celery email tasks

**Mailpit Features**:

- View HTML and plain text versions
- Inspect email headers
- Download attachments
- Search emails
- API access (<http://localhost:8025/api/messages>)

## Production (AWS SES)

AWS SES (Simple Email Service) is used for actual email delivery in production via django-anymail.

The shared AWS SES infrastructure (verified domains, IAM `ses-sender` user, SNS bounce/complaint pipeline, configuration set) lives in `services/aws/`. Apps consume it; they don't reproduce it. If `services/aws/` doesn't yet exist on your machine, see that folder's README for the foundation setup.

### Configuration

**Backend**: `anymail.backends.amazon_ses.EmailBackend`

**Environment variables** (production `.env`):

```env
DJANGO_DEFAULT_FROM_EMAIL=noreply@yourdomain.com
DJANGO_SERVER_EMAIL=server@yourdomain.com

# SES IAM credentials (the `ses-sender` IAM user in services/aws/)
DJANGO_AWS_SES_ACCESS_KEY_ID=AKIA...
DJANGO_AWS_SES_SECRET_ACCESS_KEY=...
DJANGO_AWS_SES_REGION_NAME=us-east-1
DJANGO_AWS_SES_CONFIGURATION_SET=default-feedback
```

Note: these are NOT the same credentials as `DJANGO_AWS_ACCESS_KEY_ID` (which is the S3-scoped IAM user for static file storage). Two separate IAM users, two separate scopes.

### AWS SES Setup

1. **Verify your sending domain in SES** (one-time, per domain):

   ```bash
   cd services/aws
   ./scripts/10-verify-domain.sh yourdomain.com
   # Add the printed DNS records at Cloudflare (proxy OFF)
   ./scripts/20-check-verification.sh yourdomain.com
   ```

   See `services/aws/docs/ADDING-A-DOMAIN.md` for the repeatable per-domain process.

2. **Get IAM credentials for sending**:

   If `services/aws/creds/ses-sender.json` exists on the operator machine, the credentials are already minted. Copy `access_key_id` and `secret_access_key` from that file into your secret store.

   If not, run:

   ```bash
   ./scripts/30-create-iam-sender.sh
   ```

3. **Set credentials in your deployment environment**:

   ```env
   DJANGO_AWS_SES_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
   DJANGO_AWS_SES_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

   Backed by Cloudflare Pages env vars / Hetzner `.env.production` / GitHub Actions secrets, etc. Never commit to git.

4. **Set the from address** to an address on a verified domain:

   ```env
   DJANGO_DEFAULT_FROM_EMAIL=noreply@yourdomain.com
   ```

   The SES IAM policy enforces `ses:FromAddress` matching `*@<verified-domain>` — sending as anything else will be rejected with `AccessDenied`.

### Django Settings

In `config/settings/production.py`:

```python
# Email (django-anymail with AWS SES)
EMAIL_BACKEND = "anymail.backends.amazon_ses.EmailBackend"
ANYMAIL = {
    "AMAZON_SES_CLIENT_PARAMS": {
        "region_name": env("DJANGO_AWS_SES_REGION_NAME", default="us-east-1"),
        "aws_access_key_id": env("DJANGO_AWS_SES_ACCESS_KEY_ID"),
        "aws_secret_access_key": env("DJANGO_AWS_SES_SECRET_ACCESS_KEY"),
    },
    "AMAZON_SES_CONFIGURATION_SET_NAME": env(
        "DJANGO_AWS_SES_CONFIGURATION_SET",
        default="default-feedback",
    ),
}
DEFAULT_FROM_EMAIL = env(
    "DJANGO_DEFAULT_FROM_EMAIL",
    default="noreply@example.com",
)
SERVER_EMAIL = env("DJANGO_SERVER_EMAIL", default=DEFAULT_FROM_EMAIL)
```

The `AMAZON_SES_CONFIGURATION_SET_NAME` is critical — it routes BOUNCE/COMPLAINT/DELIVERY_DELAY/REJECT events to the SNS topic configured in the SES foundation, so list hygiene and reputation issues surface immediately. Omitting it means SES still sends mail, but bounces will be invisible.

## Email Templates

Email templates are Django templates located in `backend/apps/templates/email/`.

### Template Structure

Each email has two versions:

- **HTML version**: `<template_name>.html` (styled, rich content)
- **Plain text version**: `<template_name>.txt` (fallback for text-only clients)

**Example structure**:

```tree
backend/apps/templates/email/
├── base.html           # Base HTML template
├── otp_verification.html
├── otp_verification.txt
├── password_reset.html
└── password_reset.txt
```

### Creating Email Templates

#### HTML Template (`otp_verification.html`)

```django
{% extends "email/base.html" %}

{% block content %}
<h1>Email Verification</h1>

<p>Hi {{ user.first_name }},</p>

<p>Your verification code is:</p>

<div style="font-size: 32px; font-weight: bold; letter-spacing: 8px; padding: 20px; background: #f5f5f5; border-radius: 8px; text-align: center;">
  {{ otp_code }}
</div>

<p>This code will expire in 15 minutes.</p>

<p>If you didn't request this code, please ignore this email.</p>
{% endblock %}
```

#### Plain Text Template (`otp_verification.txt`)

```django
Email Verification

Hi {{ user.first_name }},

Your verification code is: {{ otp_code }}

This code will expire in 15 minutes.

If you didn't request this code, please ignore this email.

---
{{ site_name }}
```

#### Base Template (`base.html`)

```django
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{% block title %}Email from {{ site_name }}{% endblock %}</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  {% block content %}{% endblock %}

  <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eee; font-size: 12px; color: #999;">
    <p>&copy; {% now "Y" %} {{ site_name }}. All rights reserved.</p>
  </div>
</body>
</html>
```

### Template Context Variables

Common variables available in email templates:

- `{{ user }}` - User object (user.first_name, user.email, etc.)
- `{{ site_name }}` - Site name from settings
- `{{ domain }}` - Domain from settings
- `{{ protocol }}` - http or https
- Custom variables passed when rendering

## Sending Emails

### Via Celery Task (Recommended - Async)

Celery tasks prevent blocking the request/response cycle.

**Define task** (`backend/apps/users/tasks.py`):

```python
from config.celery_app import app
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags

@app.task()
def send_otp_email(user_id: int, otp_code: str) -> None:
    """Send OTP verification email to user."""
    from apps.users.models import User

    user = User.objects.get(id=user_id)

    # Render HTML email
    html_message = render_to_string('email/otp_verification.html', {
        'user': user,
        'otp_code': otp_code,
        'site_name': 'Your App Name',
    })

    # Plain text fallback
    plain_message = render_to_string('email/otp_verification.txt', {
        'user': user,
        'otp_code': otp_code,
        'site_name': 'Your App Name',
    })

    send_mail(
        subject='Your Verification Code',
        message=plain_message,
        from_email='noreply@example.com',
        recipient_list=[user.email],
        html_message=html_message,
    )
```

**Call task**:

```python
from apps.users.tasks import send_otp_email

# Async (non-blocking)
send_otp_email.delay(user.id, otp.code)

# Sync (testing only - blocks until complete)
send_otp_email(user.id, otp.code)
```

### Direct Send (Synchronous - Use for Testing Only)

```python
from django.core.mail import send_mail

send_mail(
    subject='Test Subject',
    message='Plain text message',
    from_email='noreply@example.com',
    recipient_list=['recipient@example.com'],
    html_message='<p>HTML message</p>',
)
```

**Note**: Direct send blocks the request/response cycle. Always use Celery tasks in production!

## Email Task Tests

Testing email functionality with pytest.

### Testing Celery Tasks

**Test file** (`backend/apps/users/tests/test_tasks.py`):

```python
import pytest
from django.core import mail
from apps.users.tasks import send_otp_email
from apps.users.models import User, EmailVerificationOTP

@pytest.mark.django_db
class TestEmailTasks:
    def test_send_otp_email(self, user):
        """Test OTP email is sent correctly."""
        otp = EmailVerificationOTP.create_for_user(user)

        # Call task directly (CELERY_TASK_ALWAYS_EAGER=True in test settings)
        send_otp_email(user.id, otp.code)

        # Assert email was sent
        assert len(mail.outbox) == 1

        # Assert email content
        email = mail.outbox[0]
        assert email.subject == 'Your Verification Code'
        assert user.email in email.to
        assert otp.code in email.body
        assert otp.code in email.alternatives[0][0]  # HTML content
```

### Testing Email in Views

```python
import pytest
from django.core import mail
from rest_framework.test import APIClient

@pytest.mark.django_db
class TestRegistration:
    def test_registration_sends_otp_email(self, api_client):
        """Test registration sends OTP email."""
        response = api_client.post('/api/auth/register/', {
            'email': 'test@example.com',
            'password': 'testpass123',
            'first_name': 'Test',
            'last_name': 'User',
        })

        assert response.status_code == 201
        assert len(mail.outbox) == 1
        assert mail.outbox[0].to == ['test@example.com']
```

**Run tests**:

```bash
docker compose run --rm django pytest apps/users/tests/test_tasks.py -v
```

**Note**: In test settings (`config/settings/test.py`), `CELERY_TASK_ALWAYS_EAGER = True` makes Celery tasks run synchronously, perfect for testing.

## Monitoring Email Delivery

### Local Development (Mailpit)

- **Web UI**: <http://localhost:8025>
- **API**: <http://localhost:8025/api/messages>

**Check email was captured**:

```bash
curl http://localhost:8025/api/messages
```

### Production (AWS SES)

**SES Console**: <https://console.aws.amazon.com/ses/home?region=us-east-1>

**Where to look for delivery issues**:

- **Reputation Dashboard** (`SES Console → Reputation Metrics`) — bounce rate, complaint rate, account-level reputation. SES auto-pauses sending if bounce > 5% or complaint > 0.1%.
- **SNS topic `ses-feedback`** — every BOUNCE/COMPLAINT/DELIVERY_DELAY/REJECT event publishes here. Operator subscription emails these in real time.
- **CloudWatch metrics** — `Send`, `Bounce`, `Complaint`, `Delivery`, `Reject` counters under namespace `AWS/SES`.

**Webhook integration** (optional, recommended once apps stabilize):

Anymail can receive bounce/complaint webhooks from SES (via SNS HTTP/HTTPS subscription) and automatically suppress further sends to dead addresses. To enable:

1. Set `ANYMAIL_WEBHOOK_SECRET` in production env.
2. Add the Anymail webhook URL in your app: `path("anymail/", include("anymail.urls"))`.
3. Subscribe the SES `ses-feedback` SNS topic to `https://<your-app>/anymail/amazon_ses/tracking/`.
4. Handle `anymail.signals.tracking` in your code to suppress bounced addresses.

Until that's wired, the SNS email subscription to the operator (configured in `services/aws/scripts/40-setup-bounce-sns.sh`) is the bounce signal.

## Troubleshooting

### Emails Not Being Sent (Local)

**Check Mailpit is running**:

```bash
docker compose ps mailpit
# Should show "Up"
```

**Check Mailpit logs**:

```bash
docker compose logs mailpit
```

**Check Django email settings**:

```bash
docker compose run --rm django python manage.py shell
```

```python
from django.conf import settings
print(settings.EMAIL_HOST)  # Should be 'mailpit'
print(settings.EMAIL_PORT)  # Should be 1025
```

**Test email send**:

```bash
docker compose run --rm django python manage.py shell
```

```python
from django.core.mail import send_mail
send_mail('Test', 'Test message', 'noreply@example.com', ['test@example.com'])
# Check http://localhost:8025
```

### Emails Not Being Sent (Production)

**Check SES IAM credentials are set**:

```bash
# Inside the production container — should print AKIA...
docker compose exec django env | grep DJANGO_AWS_SES_
```

**Check the From: address is on a verified domain**:

```bash
docker compose exec django python -c "from django.conf import settings; print(settings.DEFAULT_FROM_EMAIL)"
# Must be on a domain verified in SES (see services/aws/identities/)
```

**Check Django logs**:

```bash
docker compose logs django --tail 100 | grep -i -E "email|ses|anymail"
```

**Check SES account state** (from a machine with operator AWS creds):

```bash
aws sesv2 get-account --region us-east-1 --query '{ProductionAccess: ProductionAccessEnabled, SendingEnabled: SendingEnabled, EnforcementStatus: EnforcementStatus}'
```

If `EnforcementStatus` is anything other than `HEALTHY`, SES has paused sending due to reputation issues — check the SNS feedback inbox.

**Common errors**:

- **`AccessDeniedException` on `ses:SendEmail`**: IAM policy too narrow — the `ses-sender` user must have both the identity ARN AND the configuration-set ARN in its `Resource` list, and the From: address must match the `ses:FromAddress` condition.
- **`MessageRejected: Email address is not verified`**: The account is still in SES sandbox — verify recipients individually or request production access via `services/aws/scripts/50-request-production.sh`.
- **`MailFromDomainNotVerified`**: Custom MAIL FROM (`bounces.<domain>`) not yet verified — re-run `services/aws/scripts/20-check-verification.sh <domain>`.
- **`The config profile () could not be found`**: A subprocess set `AWS_PROFILE=""` instead of unsetting it. Use `env -u AWS_PROFILE`.
- **Mail goes out but recipients report it lands in spam**: Check Gmail's `Authentication-Results` header on a real send — you want `dkim=pass spf=pass dmarc=pass`. Failures usually trace to DNS records at Cloudflare with proxy ON instead of OFF.

### Celery Tasks Not Running

**Check Celery worker is running**:

```bash
docker compose ps celeryworker
# Should show "Up"
```

**Check Celery logs**:

```bash
docker compose logs -f celeryworker
```

**Check task was queued**:

```bash
docker compose run --rm django python manage.py shell
```

```python
from config.celery_app import app
inspector = app.control.inspect()
print(inspector.active())      # Currently running tasks
print(inspector.scheduled())   # Scheduled tasks
print(inspector.reserved())    # Queued tasks
```

**Restart Celery worker**:

```bash
docker compose restart celeryworker
```

### Template Not Found

**Check template path**:

```bash
# Templates should be in backend/apps/templates/email/
ls -la backend/apps/templates/email/
```

**Check TEMPLATES setting** (`config/settings/base.py`):

```python
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [str(APPS_DIR / "templates")],  # Should include templates dir
        ...
    }
]
```

**Test template rendering**:

```bash
docker compose run --rm django python manage.py shell
```

```python
from django.template.loader import render_to_string
html = render_to_string('email/otp_verification.html', {'otp_code': '123456'})
print(html)
```

## Email Best Practices

1. **Always send HTML + plain text versions** - Some clients don't support HTML
2. **Use Celery for async delivery** - Don't block request/response cycle
3. **Test in multiple email clients** - Gmail, Outlook, Apple Mail, etc.
4. **Keep subject lines short** - 50 characters or less
5. **Include unsubscribe link** - Required by law for marketing emails
6. **Verify sender domain** - Improves deliverability
7. **Monitor bounce rates** - Clean up invalid email addresses
8. **Use templates** - Consistent branding and easier maintenance
9. **Test locally with Mailpit** - Catch issues before production
10. **Log email sends** - Track delivery for debugging

## Example: Complete Email Flow

Here's a complete example of the OTP verification email flow:

### 1. Model (`backend/apps/users/models.py`)

```python
class EmailVerificationOTP(TimeStampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    code = models.CharField(max_length=6)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)

    @classmethod
    def create_for_user(cls, user):
        code = ''.join(random.choices(string.digits, k=6))
        expires_at = timezone.now() + timedelta(minutes=15)
        return cls.objects.create(user=user, code=code, expires_at=expires_at)
```

### 2. Celery Task (`backend/apps/users/tasks.py`)

```python
@app.task()
def send_otp_email(user_id, otp_code):
    user = User.objects.get(id=user_id)

    html_message = render_to_string('email/otp_verification.html', {
        'user': user,
        'otp_code': otp_code,
    })

    plain_message = render_to_string('email/otp_verification.txt', {
        'user': user,
        'otp_code': otp_code,
    })

    send_mail(
        subject='Your Verification Code',
        message=plain_message,
        from_email='noreply@example.com',
        recipient_list=[user.email],
        html_message=html_message,
    )
```

### 3. Serializer (`backend/apps/users/api/serializers.py`)

```python
class UserRegistrationSerializer(serializers.ModelSerializer):
    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)

        # Generate OTP
        otp = EmailVerificationOTP.create_for_user(user)

        # Send email via Celery
        send_otp_email.delay(user.id, otp.code)

        return user
```

### 4. View (`backend/apps/users/api/views.py`)

```python
class UserRegistrationView(CreateAPIView):
    serializer_class = UserRegistrationSerializer
    permission_classes = [AllowAny]
```

### 5. Test (`backend/apps/users/tests/test_registration.py`)

```python
@pytest.mark.django_db
def test_registration_sends_otp_email(api_client):
    response = api_client.post('/api/auth/register/', {
        'email': 'test@example.com',
        'password': 'testpass123',
        'first_name': 'Test',
        'last_name': 'User',
    })

    assert response.status_code == 201
    assert len(mail.outbox) == 1
    assert 'Your Verification Code' in mail.outbox[0].subject
```

This flow ensures:

- ✅ User registration creates OTP
- ✅ Email sent asynchronously via Celery
- ✅ HTML and plain text versions included
- ✅ Email captured in Mailpit (local) or sent via AWS SES (production)
- ✅ Comprehensive test coverage
