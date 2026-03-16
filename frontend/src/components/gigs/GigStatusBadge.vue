<script setup lang="ts">
import { computed } from 'vue'
import { Badge } from '@/components/ui/badge'

const props = defineProps<{
  status: string
}>()

interface StatusConfig {
  label: string
  classes: string
}

const statusMap: Record<string, StatusConfig> = {
  draft: { label: 'Draft', classes: 'bg-gray-100 text-gray-700 border-gray-200 dark:bg-gray-800 dark:text-gray-300 dark:border-gray-700' },
  posted: { label: 'Posted', classes: 'bg-blue-100 text-blue-700 border-blue-200 dark:bg-blue-900 dark:text-blue-300 dark:border-blue-800' },
  invited: { label: 'Invited', classes: 'bg-indigo-100 text-indigo-700 border-indigo-200 dark:bg-indigo-900 dark:text-indigo-300 dark:border-indigo-800' },
  negotiating: { label: 'Negotiating', classes: 'bg-yellow-100 text-yellow-700 border-yellow-200 dark:bg-yellow-900 dark:text-yellow-300 dark:border-yellow-800' },
  accepted: { label: 'Accepted', classes: 'bg-green-100 text-green-700 border-green-200 dark:bg-green-900 dark:text-green-300 dark:border-green-800' },
  in_progress: { label: 'In Progress', classes: 'bg-emerald-100 text-emerald-700 border-emerald-200 dark:bg-emerald-900 dark:text-emerald-300 dark:border-emerald-800' },
  completed: { label: 'Completed', classes: 'bg-teal-100 text-teal-700 border-teal-200 dark:bg-teal-900 dark:text-teal-300 dark:border-teal-800' },
  cancelled: { label: 'Cancelled', classes: 'bg-red-100 text-red-700 border-red-200 dark:bg-red-900 dark:text-red-300 dark:border-red-800' },
  disputed: { label: 'Disputed', classes: 'bg-orange-100 text-orange-700 border-orange-200 dark:bg-orange-900 dark:text-orange-300 dark:border-orange-800' },
}

const config = computed<StatusConfig>(() => {
  return statusMap[props.status] ?? { label: props.status, classes: 'bg-gray-100 text-gray-700' }
})
</script>

<template>
  <Badge variant="outline" :class="config.classes">
    {{ config.label }}
  </Badge>
</template>
