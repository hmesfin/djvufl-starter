<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useProfessionals } from '@/composables/useProfessionals'
import { Card, CardHeader, CardTitle, CardContent, CardFooter } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { Checkbox } from '@/components/ui/checkbox'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import type { SpecializationsEnum } from '@/api/types.gen'

const router = useRouter()
const { createProfile, fetchServiceAreas, serviceAreas, isLoading, error } = useProfessionals()

// Step management
const currentStep = ref(1)
const totalSteps = 5
const isSubmitting = ref(false)
const submitSuccess = ref(false)

// Form state
const licenseNumber = ref('')
const selectedServiceAreaUuids = ref<string[]>([])
const selectedSpecializations = ref<SpecializationsEnum[]>([])
const bio = ref('')

const specializationOptions: Array<{ value: SpecializationsEnum; label: string }> = [
  { value: 'residential', label: 'Residential' },
  { value: 'commercial', label: 'Commercial' },
  { value: 'buyers_agent', label: "Buyer's Agent" },
  { value: 'listing_agent', label: 'Listing Agent' },
]

// Validation
const stepValid = computed((): boolean => {
  switch (currentStep.value) {
    case 1:
      return licenseNumber.value.trim().length > 0
    case 2:
      return selectedServiceAreaUuids.value.length > 0
    case 3:
      return selectedSpecializations.value.length > 0
    case 4:
      return true // bio is optional
    case 5:
      return true
    default:
      return false
  }
})

function nextStep(): void {
  if (currentStep.value < totalSteps && stepValid.value) {
    currentStep.value++
  }
}

function prevStep(): void {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

function toggleServiceArea(uuid: string): void {
  const idx = selectedServiceAreaUuids.value.indexOf(uuid)
  if (idx === -1) {
    selectedServiceAreaUuids.value.push(uuid)
  } else {
    selectedServiceAreaUuids.value.splice(idx, 1)
  }
}

function toggleSpecialization(spec: SpecializationsEnum): void {
  const idx = selectedSpecializations.value.indexOf(spec)
  if (idx === -1) {
    selectedSpecializations.value.push(spec)
  } else {
    selectedSpecializations.value.splice(idx, 1)
  }
}

function getServiceAreaName(uuid: string): string {
  const area = serviceAreas.value.find((a) => a.uuid === uuid)
  return area?.name ?? uuid
}

function getSpecializationLabel(spec: SpecializationsEnum): string {
  const option = specializationOptions.find((o) => o.value === spec)
  return option?.label ?? spec
}

async function handleSubmit(): Promise<void> {
  isSubmitting.value = true
  error.value = null

  const result = await createProfile({
    license_number: licenseNumber.value.trim(),
    bio: bio.value.trim() || undefined,
    specializations: selectedSpecializations.value,
    service_area_uuids: selectedServiceAreaUuids.value,
  })

  isSubmitting.value = false

  if (result.success) {
    submitSuccess.value = true
  }
}

function goToDashboard(): void {
  router.push({ name: 'dashboard' })
}

onMounted(async () => {
  await fetchServiceAreas()
})
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <!-- Success state -->
    <Card v-if="submitSuccess" class="text-center">
      <CardHeader>
        <CardTitle class="text-2xl">Profile Submitted</CardTitle>
      </CardHeader>
      <CardContent class="space-y-4">
        <p class="text-muted-foreground">
          Your professional profile has been submitted and is pending verification.
          You will be notified once your license has been reviewed.
        </p>
        <Badge variant="secondary" class="text-sm">
          Verification Pending
        </Badge>
      </CardContent>
      <CardFooter class="justify-center">
        <Button @click="goToDashboard">Go to Dashboard</Button>
      </CardFooter>
    </Card>

    <!-- Onboarding form -->
    <Card v-else>
      <CardHeader>
        <div class="flex items-center justify-between">
          <CardTitle class="text-2xl">Professional Onboarding</CardTitle>
          <span class="text-sm text-muted-foreground">
            Step {{ currentStep }} of {{ totalSteps }}
          </span>
        </div>
        <!-- Progress bar -->
        <div class="w-full bg-muted rounded-full h-2 mt-4">
          <div
            class="bg-primary h-2 rounded-full transition-all duration-300"
            :style="{ width: `${(currentStep / totalSteps) * 100}%` }"
          />
        </div>
      </CardHeader>

      <CardContent class="min-h-[280px]">
        <!-- Step 1: License Info -->
        <div v-if="currentStep === 1" class="space-y-4">
          <div>
            <h3 class="text-lg font-semibold mb-2">License Information</h3>
            <p class="text-sm text-muted-foreground mb-4">
              Enter your real estate license number. This will be verified by our team.
            </p>
          </div>
          <div class="space-y-2">
            <Label for="license-number">License Number</Label>
            <Input
              id="license-number"
              v-model="licenseNumber"
              placeholder="e.g., RS-123456"
              type="text"
            />
          </div>
        </div>

        <!-- Step 2: Service Areas -->
        <div v-if="currentStep === 2" class="space-y-4">
          <div>
            <h3 class="text-lg font-semibold mb-2">Service Areas</h3>
            <p class="text-sm text-muted-foreground mb-4">
              Select the neighborhoods where you operate.
            </p>
          </div>
          <div v-if="serviceAreas.length === 0" class="text-sm text-muted-foreground">
            No service areas available. Please contact support.
          </div>
          <div v-else class="grid gap-3">
            <label
              v-for="area in serviceAreas"
              :key="area.uuid"
              class="flex items-center gap-3 p-3 rounded-lg border border-border hover:bg-accent/50 cursor-pointer transition-colors"
              :class="{ 'bg-accent border-primary': selectedServiceAreaUuids.includes(area.uuid) }"
            >
              <Checkbox
                :checked="selectedServiceAreaUuids.includes(area.uuid)"
                @update:checked="toggleServiceArea(area.uuid)"
              />
              <div>
                <span class="text-sm font-medium">{{ area.name }}</span>
                <span v-if="area.metro" class="text-xs text-muted-foreground ml-2">
                  {{ area.metro.name }}, {{ area.metro.state }}
                </span>
              </div>
            </label>
          </div>
        </div>

        <!-- Step 3: Specializations -->
        <div v-if="currentStep === 3" class="space-y-4">
          <div>
            <h3 class="text-lg font-semibold mb-2">Specializations</h3>
            <p class="text-sm text-muted-foreground mb-4">
              Select the types of real estate work you specialize in.
            </p>
          </div>
          <div class="grid gap-3">
            <label
              v-for="spec in specializationOptions"
              :key="spec.value"
              class="flex items-center gap-3 p-3 rounded-lg border border-border hover:bg-accent/50 cursor-pointer transition-colors"
              :class="{ 'bg-accent border-primary': selectedSpecializations.includes(spec.value) }"
            >
              <Checkbox
                :checked="selectedSpecializations.includes(spec.value)"
                @update:checked="toggleSpecialization(spec.value)"
              />
              <span class="text-sm font-medium">{{ spec.label }}</span>
            </label>
          </div>
        </div>

        <!-- Step 4: Bio -->
        <div v-if="currentStep === 4" class="space-y-4">
          <div>
            <h3 class="text-lg font-semibold mb-2">Professional Bio</h3>
            <p class="text-sm text-muted-foreground mb-4">
              Tell other agents about yourself. This is optional but helps build trust.
            </p>
          </div>
          <div class="space-y-2">
            <Label for="bio">Bio</Label>
            <Textarea
              id="bio"
              v-model="bio"
              placeholder="Years of experience, areas of expertise, what makes you a great agent to work with..."
              rows="6"
            />
          </div>
        </div>

        <!-- Step 5: Review & Submit -->
        <div v-if="currentStep === 5" class="space-y-6">
          <div>
            <h3 class="text-lg font-semibold mb-2">Review Your Profile</h3>
            <p class="text-sm text-muted-foreground mb-4">
              Please review your information before submitting.
            </p>
          </div>

          <div class="space-y-4">
            <div>
              <span class="text-sm font-medium text-muted-foreground">License Number</span>
              <p class="text-sm mt-1">{{ licenseNumber }}</p>
            </div>

            <div>
              <span class="text-sm font-medium text-muted-foreground">Service Areas</span>
              <div class="flex flex-wrap gap-2 mt-1">
                <Badge
                  v-for="uuid in selectedServiceAreaUuids"
                  :key="uuid"
                  variant="secondary"
                >
                  {{ getServiceAreaName(uuid) }}
                </Badge>
              </div>
            </div>

            <div>
              <span class="text-sm font-medium text-muted-foreground">Specializations</span>
              <div class="flex flex-wrap gap-2 mt-1">
                <Badge
                  v-for="spec in selectedSpecializations"
                  :key="spec"
                  variant="secondary"
                >
                  {{ getSpecializationLabel(spec) }}
                </Badge>
              </div>
            </div>

            <div v-if="bio.trim()">
              <span class="text-sm font-medium text-muted-foreground">Bio</span>
              <p class="text-sm mt-1 whitespace-pre-wrap">{{ bio }}</p>
            </div>
          </div>

          <div v-if="error" class="text-sm text-destructive">
            {{ error.message }}
          </div>
        </div>
      </CardContent>

      <CardFooter class="flex justify-between">
        <Button
          v-if="currentStep > 1"
          variant="outline"
          :disabled="isSubmitting"
          @click="prevStep"
        >
          Back
        </Button>
        <div v-else />

        <Button
          v-if="currentStep < totalSteps"
          :disabled="!stepValid"
          @click="nextStep"
        >
          Next
        </Button>
        <Button
          v-else
          :disabled="isSubmitting || isLoading"
          @click="handleSubmit"
        >
          <span v-if="isSubmitting">Submitting...</span>
          <span v-else>Submit Profile</span>
        </Button>
      </CardFooter>
    </Card>
  </div>
</template>
