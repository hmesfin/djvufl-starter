<script setup lang="ts">
import { useRouter } from 'vue-router'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { CheckCircle } from 'lucide-vue-next'

const router = useRouter()

function goToDashboard(): void {
  router.push({ name: 'dashboard' })
}
</script>

<template>
  <div class="flex items-center justify-center min-h-[60vh]">
    <Card class="max-w-md w-full text-center">
      <CardHeader>
        <div class="flex justify-center mb-4">
          <CheckCircle :size="48" class="text-green-500" />
        </div>
        <CardTitle class="text-2xl">Payment Account Connected!</CardTitle>
        <CardDescription>
          You can now receive payments for completed gigs.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Button class="w-full" @click="goToDashboard">
          Go to Dashboard
        </Button>
      </CardContent>
    </Card>
  </div>
</template>
