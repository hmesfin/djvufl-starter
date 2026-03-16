<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useGigs } from '@/composables/useGigs'
import { useProfessionals } from '@/composables/useProfessionals'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Checkbox } from '@/components/ui/checkbox'
import { Loader2 } from 'lucide-vue-next'
import type { GigCreateRequestWritable, GigTypeEnum } from '@/api/types.gen'

const router = useRouter()
const { createGig, transitionGig, isLoading, error } = useGigs()
const { serviceAreas, fetchServiceAreas } = useProfessionals()

// Form state
const title = ref('')
const description = ref('')
const locationAddress = ref('')
const serviceAreaUuid = ref<string>('')
const scheduledDate = ref('')
const scheduledTime = ref('')
const budgetRangeMin = ref('')
const budgetRangeMax = ref('')
const gigType = ref<GigTypeEnum>('showing')
const postImmediately = ref(false)

const gigTypeOptions: Array<{ value: GigTypeEnum; label: string }> = [
  { value: 'showing', label: 'Showing' },
  { value: 'open_house', label: 'Open House' },
  { value: 'inspection_accompaniment', label: 'Inspection Accompaniment' },
  { value: 'other', label: 'Other' },
]

onMounted(async () => {
  await fetchServiceAreas()
})

async function handleSubmit(): Promise<void> {
  const data: GigCreateRequestWritable = {
    title: title.value,
    description: description.value || undefined,
    location_address: locationAddress.value,
    service_area_uuid: serviceAreaUuid.value || null,
    scheduled_date: scheduledDate.value,
    scheduled_time: scheduledTime.value,
    budget_range_min: budgetRangeMin.value || null,
    budget_range_max: budgetRangeMax.value || null,
    gig_type: gigType.value,
  }

  const result = await createGig(data)

  if (!result.success || !result.gig) {
    return
  }

  // If the gig was created successfully, the backend returns a GigCreate
  // which doesn't have a uuid. We need to fetch the gig list to get it,
  // or the create response may include it. Let's check the title match.
  // Actually, the create endpoint returns the created object. Let's use
  // the title to navigate to the list for now, or transition if needed.

  // After creation, if user wants to post immediately, we need the gig uuid.
  // The GigCreate type doesn't include uuid, so we fetch gigs to find it.
  if (postImmediately.value) {
    // Fetch my gigs and find the newly created one
    const { useGigs: useGigsRefresh } = await import('@/composables/useGigs')
    const refreshGigs = useGigsRefresh()
    await refreshGigs.fetchMyGigs()
    const newGig = refreshGigs.myGigs.value.find((g) => g.title === data.title && g.status === 'draft')
    if (newGig) {
      await transitionGig(newGig.uuid, 'posted')
      router.push({ name: 'gig-detail', params: { uuid: newGig.uuid } })
      return
    }
  }

  // Navigate to gig list
  router.push({ name: 'gig-list' })
}
</script>

<template>
  <div class="max-w-2xl mx-auto">
    <Card>
      <CardHeader>
        <CardTitle>Create a New Gig</CardTitle>
        <CardDescription>
          Post a gig for another agent to handle on your behalf
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form class="space-y-6" @submit.prevent="handleSubmit">
          <!-- Error display -->
          <div
            v-if="error"
            class="rounded-md bg-destructive/10 p-3 text-sm text-destructive"
          >
            {{ error.message }}
          </div>

          <!-- Title -->
          <div class="space-y-2">
            <Label for="title">Title</Label>
            <Input
              id="title"
              v-model="title"
              placeholder="e.g. Showing at 123 Main St"
              required
            />
          </div>

          <!-- Description -->
          <div class="space-y-2">
            <Label for="description">Description</Label>
            <Textarea
              id="description"
              v-model="description"
              placeholder="Describe the gig requirements, property details, and any special instructions..."
              rows="4"
            />
          </div>

          <!-- Location -->
          <div class="space-y-2">
            <Label for="location">Location Address</Label>
            <Input
              id="location"
              v-model="locationAddress"
              placeholder="123 Main St, City, State ZIP"
              required
            />
          </div>

          <!-- Service Area -->
          <div class="space-y-2">
            <Label>Service Area</Label>
            <Select v-model="serviceAreaUuid">
              <SelectTrigger>
                <SelectValue placeholder="Select a service area" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem
                  v-for="area in serviceAreas"
                  :key="area.uuid"
                  :value="area.uuid"
                >
                  {{ area.name }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>

          <!-- Date and Time -->
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="date">Scheduled Date</Label>
              <Input
                id="date"
                v-model="scheduledDate"
                type="date"
                required
              />
            </div>
            <div class="space-y-2">
              <Label for="time">Scheduled Time</Label>
              <Input
                id="time"
                v-model="scheduledTime"
                type="time"
                required
              />
            </div>
          </div>

          <!-- Budget Range -->
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="budget-min">Budget Min ($)</Label>
              <Input
                id="budget-min"
                v-model="budgetRangeMin"
                type="number"
                min="0"
                step="0.01"
                placeholder="50.00"
              />
            </div>
            <div class="space-y-2">
              <Label for="budget-max">Budget Max ($)</Label>
              <Input
                id="budget-max"
                v-model="budgetRangeMax"
                type="number"
                min="0"
                step="0.01"
                placeholder="150.00"
              />
            </div>
          </div>

          <!-- Gig Type -->
          <div class="space-y-2">
            <Label>Gig Type</Label>
            <Select v-model="gigType">
              <SelectTrigger>
                <SelectValue placeholder="Select gig type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem
                  v-for="option in gigTypeOptions"
                  :key="option.value"
                  :value="option.value"
                >
                  {{ option.label }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>

          <!-- Post immediately checkbox -->
          <div class="flex items-center gap-2">
            <Checkbox
              id="post-immediately"
              :checked="postImmediately"
              @update:checked="(val: boolean | 'indeterminate') => postImmediately = val === true"
            />
            <Label for="post-immediately" class="cursor-pointer">
              Post to marketplace immediately after creation
            </Label>
          </div>

          <!-- Submit -->
          <div class="flex gap-3 justify-end">
            <Button
              type="button"
              variant="outline"
              @click="router.push({ name: 'gig-list' })"
            >
              Cancel
            </Button>
            <Button type="submit" :disabled="isLoading">
              <Loader2 v-if="isLoading" :size="16" class="mr-2 animate-spin" />
              {{ postImmediately ? 'Create & Post' : 'Create as Draft' }}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  </div>
</template>
