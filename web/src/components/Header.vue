<template>
  <div id="header-container">
    <header>
      <router-link to="/">
        <div class="logo">Microverse</div>
      </router-link>

      <div class="menu-items">
        <router-link to="/tutorial">
          <span>How to play</span>
        </router-link>

        <router-link to="/my_vault">
          <span>My vault</span>
        </router-link>
      </div>
    </header>
  </div>
</template>

<script>
export default {
  name: 'Header'
}
</script>
