<template>
  <v-app>
    <v-app-bar theme="dark" prominent>
      <v-app-bar-nav-icon variant="text" @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
      <v-toolbar-title>KVM TEST CASE ANALYZING</v-toolbar-title>
    </v-app-bar>
    <v-navigation-drawer
        v-model="drawer"
        theme="dark"
        temporary
      >
      <v-list>
        <v-list-item prepend-icon="mdi-home" title="Home"></v-list-item>
        <v-list-group value="case_analysis">
            <template v-slot:activator="{ props }">
              <v-list-item
                v-bind="props"
                prepend-icon="mdi-hammer-wrench"
                title="Case Analysis"
              ></v-list-item>
            </template>
  
            <v-list-item
              prepend-icon="mdi-chart-pie"
              title="Statistics"
              value="case_statistics"
              to="/"
            >
            </v-list-item>
          </v-list-group>
          <v-list-item prepend-icon="mdi-information" title="About" to="/about"></v-list-item>
      </v-list>
    </v-navigation-drawer>
    <v-main>
        <router-view name="content"></router-view>
    </v-main>
    <v-footer absolute>
      <div class="px-4 py-2 bg-black text-center w-100">KVM Test Case Analyzing @2022</div>
    </v-footer>
  </v-app>
</template>

<script>
export default {
  name: "App",
  data() {
    return {
      drawer: false,
    }
  }
};
</script>
