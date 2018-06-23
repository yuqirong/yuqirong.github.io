<div class="site-brand-wrapper">
  <div class="site-meta {% if theme.custom_logo.enabled %}custom-logo{% endif %}">
    {% if theme.custom_logo.image and theme.scheme === 'Muse' %}
      <div class="site-meta-headline">
        <a>
          <img class="custom-logo-image" src="{{ theme.custom_logo.image }}"
               alt="{{ title }}"/>
        </a>
      </div>
    {% endif %}

    <div class="custom-logo-site-title">
      <a href="{{ config.root }}" rel="start" class="brand">
        <span class="logo-line-before"><i></i></span>
        <span class="site-title" style="opacity: 1; top: 0px;">Colourful Day</span>
        <!--<img src="http://ofyt9w4c2.bkt.clouddn.com/avatar/1529736707_477636.png" style="background:#222222"/>-->
        <span class="logo-line-after"><i></i></span>
      </a>
    </div>
      {% if theme.seo %}
        <h1 class="site-subtitle" itemprop="description">我需要，最狂的风，和最静的海。</h1>
        <h1 class="site-subtitle" itemprop="description" style="margin-top:0px;">——顾城《第八个早晨》</h1>
      {% else %}
        <p class="site-subtitle">我需要，最狂的风，和最静的海。</p>
        <p class="site-subtitle" itemprop="description" style="margin-top:0px;">——顾城《第八个早晨》</p>
      {% endif %}
  </div>

  <div class="site-nav-toggle">
    <button aria-label="{{ __('accessibility.nav_toggle') }}">
      <span class="btn-bar"></span>
      <span class="btn-bar"></span>
      <span class="btn-bar"></span>
    </button>
  </div>
</div>
