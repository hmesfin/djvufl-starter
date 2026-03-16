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
  pending: {
    label: 'Pending',
    classes:
      'bg-yellow-100 text-yellow-700 border-yellow-200 dark:bg-yellow-900 dark:text-yellow-300 dark:border-yellow-800',
  },
  captured: {
    label: 'Captured',
    classes:
      'bg-blue-100 text-blue-700 border-blue-200 dark:bg-blue-900 dark:text-blue-300 dark:border-blue-800',
  },
  released: {
    label: 'Released',
    classes:
      'bg-green-100 text-green-700 border-green-200 dark:bg-green-900 dark:text-green-300 dark:border-green-800',
  },
  refunded: {
    label: 'Refunded',
    classes:
      'bg-orange-100 text-orange-700 border-orange-200 dark:bg-orange-900 dark:text-orange-300 dark:border-orange-800',
  },
  failed: {
    label: 'Failed',
    classes:
      'bg-red-100 text-red-700 border-red-200 dark:bg-red-900 dark:text-red-300 dark:border-red-800',
  },
}

const config = computed<StatusConfig>(() => {
  return (
    statusMap[props.status] ?? {
      label: props.status,
      classes: 'bg-gray-100 text-gray-700',
    }
  )
})
</script>

<template>
  <Badge variant="outline" :class="config.classes">
    {{ config.label }}
  </Badge>
</template>
