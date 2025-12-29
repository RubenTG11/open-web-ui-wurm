<script lang="ts">
	import { models, showSettings, settings, user, mobile, config } from '$lib/stores';
	import { onMount, tick, getContext } from 'svelte';
	import { toast } from 'svelte-sonner';
	import Selector from './ModelSelector/Selector.svelte';
	import Tooltip from '../common/Tooltip.svelte';

	import { updateUserSettings } from '$lib/apis/users';
	const i18n = getContext('i18n');

	export let selectedModels = ['wurm-ki'];
	export let disabled = false;

	export let showSetDefault = true;

	// Lock to wurm-ki model
	$: selectedModels = ['wurm-ki'];

	const saveDefaultModel = async () => {
		const hasEmptyModel = selectedModels.filter((it) => it === '');
		if (hasEmptyModel.length) {
			toast.error($i18n.t('Choose a model before saving...'));
			return;
		}
		settings.set({ ...$settings, models: selectedModels });
		await updateUserSettings(localStorage.token, { ui: $settings });

		toast.success($i18n.t('Default model updated'));
	};

	const pinModelHandler = async (modelId) => {
		let pinnedModels = $settings?.pinnedModels ?? [];

		if (pinnedModels.includes(modelId)) {
			pinnedModels = pinnedModels.filter((id) => id !== modelId);
		} else {
			pinnedModels = [...new Set([...pinnedModels, modelId])];
		}

		settings.set({ ...$settings, pinnedModels: pinnedModels });
		await updateUserSettings(localStorage.token, { ui: $settings });
	};

	$: if (selectedModels.length > 0 && $models.length > 0) {
		const _selectedModels = selectedModels.map((model) =>
			$models.map((m) => m.id).includes(model) ? model : ''
		);

		if (JSON.stringify(_selectedModels) !== JSON.stringify(selectedModels)) {
			selectedModels = _selectedModels;
		}
	}
</script>

<div class="flex flex-col w-full items-start">
	<!-- Locked Wurm-Ki Model Display -->
	<div class="flex w-full max-w-fit">
		<div class="overflow-hidden w-full">
			<div class="max-w-full {($settings?.highContrastMode ?? false) ? 'm-1' : 'mr-1'}">
				<div class="flex items-center gap-2 px-3 py-2 text-lg font-medium text-gray-700 dark:text-gray-100">
					<img
						src="/img/logo_small.png"
						alt="Wurm-Ki"
						class="rounded-full size-5"
					/>
					<span>Wurm-Ki</span>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Set as default button hidden for locked model -->
