from django.core.management.base import BaseCommand

from apps.professionals.models import Metro, ServiceArea

MSP_AREAS = [
    {"name": "Downtown Minneapolis", "zip_codes": ["55401", "55402", "55403"]},
    {"name": "Uptown", "zip_codes": ["55408", "55405"]},
    {"name": "Northeast Minneapolis", "zip_codes": ["55413", "55418"]},
    {"name": "South Minneapolis", "zip_codes": ["55406", "55407", "55409", "55417"]},
    {"name": "North Minneapolis", "zip_codes": ["55411", "55412"]},
    {"name": "Downtown St. Paul", "zip_codes": ["55101", "55102"]},
    {"name": "Highland Park", "zip_codes": ["55116"]},
    {"name": "Edina", "zip_codes": ["55424", "55435", "55436", "55439"]},
    {"name": "Bloomington", "zip_codes": ["55420", "55425", "55431", "55437", "55438"]},
    {"name": "Plymouth", "zip_codes": ["55441", "55442", "55446", "55447"]},
    {"name": "Maple Grove", "zip_codes": ["55311", "55369"]},
    {"name": "Woodbury", "zip_codes": ["55125", "55129"]},
    {"name": "Eagan", "zip_codes": ["55121", "55122", "55123"]},
    {"name": "Eden Prairie", "zip_codes": ["55344", "55346", "55347"]},
    {"name": "Burnsville", "zip_codes": ["55306", "55337"]},
    {"name": "Lakeville", "zip_codes": ["55044"]},
    {"name": "Minnetonka", "zip_codes": ["55305", "55345"]},
    {"name": "St. Louis Park", "zip_codes": ["55416", "55426"]},
    {"name": "Richfield", "zip_codes": ["55423"]},
    {"name": "Hopkins", "zip_codes": ["55343"]},
]


class Command(BaseCommand):
    help = "Seed MSP metro service areas"

    def handle(self, *args, **options):
        metro, _ = Metro.objects.get_or_create(
            name="Minneapolis-St. Paul",
            state="MN",
        )
        for area_data in MSP_AREAS:
            ServiceArea.objects.update_or_create(
                name=area_data["name"],
                metro=metro,
                defaults={"zip_codes": area_data["zip_codes"]},
            )
        self.stdout.write(self.style.SUCCESS(f"Seeded {len(MSP_AREAS)} service areas"))
