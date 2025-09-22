   document.getElementById('year').textContent = new Date().getFullYear();

   const projects = [
	 {
		 title: 'Webserv',
		 description: 'Webserver implemented from scratch in C++98, supporting HTTP/1.1 and CGI.',
		 image: 'https://raw.githubusercontent.com/lulebugl/lulebugl/main/.github/images/webserv.png',
		 tech: ['C++98', 'Socket', 'multiplexing'],
		 link: 'https://github.com/lulebugl/webserv'
	 },
	 {
	   title: 'Cub3D',
	   description: 'first-person 3D maze explorer created from scratch where players navigate through custom mazes while deactiving overheating cores.',
	   image: 'https://github.com/lulebugl/cub3D/raw/main/assets/readme_assets/gameplay.png',
	   tech: ['C', 'Raycasting', 'Minilibx'],
	   link: 'https://github.com/lulebugl/cub3D'
	 },
	 {
	   title: 'Minishell',
	   description: 'Recreating basic bash in C.',
	   image: 'https://raw.githubusercontent.com/lulebugl/lulebugl/main/.github/images/minishell.png',
	   tech: ['C', 'Shell'],
	   link: 'https://github.com/lulebugl/minishell'
	 }
   ];

   const slidesRoot = document.getElementById('carousel-slides');
   const dotsRoot = document.getElementById('carousel-dots');
   const btnPrev = document.getElementById('btn-prev');
   const btnNext = document.getElementById('btn-next');

   let currentIndex = 0;
   let isAnimating = false;
   let autoTimer = null;

  function classesForIndex(i, n) {
     if (i === currentIndex) return 'opacity-100 translate-x-0 scale-100 z-30';
     if (i === (currentIndex + 1) % n) return 'opacity-90 translate-x-[17%] scale-95 z-20';
     if (i === (currentIndex - 1 + n) % n) return 'opacity-90 -translate-x-[17%] scale-95 z-20';
     return 'opacity-0 translate-x-[60%] scale-75 z-10';
  }

   function renderSlides() {
	 const n = projects.length;
	 slidesRoot.innerHTML = projects.map((p, i) => {
	   const pos = classesForIndex(i, n);
	   const techBadges = (p.tech || []).map(t => `<span class="px-3 py-1 bg-indigo-50 text-indigo-700 rounded-full text-sm">${t}</span>`).join('');
	   return `
		 <div class="absolute inset-0 transition-all duration-700 ease-in-out ${pos}">
		   <div class="relative h-full bg-white rounded-2xl overflow-hidden shadow-xl ring-1 ring-gray-200">
			 <img src="${p.image || 'https://via.placeholder.com/1200x800?text=Project'}" alt="${p.title}" class="w-full h-2/3 object-cover" />
			 <div class="absolute inset-0 bg-gradient-to-t from-white/90 via-transparent to-transparent"></div>
			 <div class="absolute bottom-0 left-0 right-0 p-8">
			   <div class="flex items-start justify-between mb-4">
				 <h3 class="text-2xl font-semibold">${p.title}</h3>
				 <a href="${p.link || '#'}" class="p-2 rounded-md hover:bg-gray-100 text-gray-700" aria-label="Open project" target="_blank" rel="noopener noreferrer">
				   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
					 <path stroke-linecap="round" stroke-linejoin="round" d="M18 13v6a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/>
					 <path stroke-linecap="round" stroke-linejoin="round" d="M15 3h6v6"/>
					 <path stroke-linecap="round" stroke-linejoin="round" d="M10 14L21 3"/>
				   </svg>
				 </a>
			   </div>
			   <p class="text-gray-600 mb-4">${p.description || ''}</p>
			   <div class="flex flex-wrap gap-2">${techBadges}</div>
			 </div>
		   </div>
		 </div>
	   `;
	 }).join('');

	 dotsRoot.innerHTML = projects.map((_, i) => {
	   const active = i === currentIndex ? 'bg-indigo-600' : 'bg-gray-300';
	   return `<button data-idx="${i}" class="w-2.5 h-2.5 rounded-full ${active}"></button>`;
	 }).join('');

	 // Attach dot handlers
	 Array.from(dotsRoot.querySelectorAll('button')).forEach(btn => {
	   btn.addEventListener('click', () => {
		 const idx = Number(btn.getAttribute('data-idx'));
		 if (Number.isInteger(idx)) {
		   currentIndex = idx;
		   renderSlides();
		   restartAuto();
		 }
	   });
	 });
   }

   function nextProject() {
	 if (isAnimating) return;
	 isAnimating = true;
	 setTimeout(() => { isAnimating = false; }, 300);
	 currentIndex = (currentIndex + 1) % projects.length;
	 renderSlides();
   }

   function prevProject() {
	 if (isAnimating) return;
	 isAnimating = true;
	 setTimeout(() => { isAnimating = false; }, 300);
	 currentIndex = (currentIndex - 1 + projects.length) % projects.length;
	 renderSlides();
   }

   function startAuto() {
	 stopAuto();
	 autoTimer = setInterval(nextProject, 5000);
   }

   function stopAuto() {
	 if (autoTimer) clearInterval(autoTimer);
	 autoTimer = null;
   }

   function restartAuto() {
	 startAuto();
   }

   btnNext.addEventListener('click', () => { nextProject(); restartAuto(); });
   btnPrev.addEventListener('click', () => { prevProject(); restartAuto(); });

   slidesRoot.addEventListener('mouseenter', stopAuto);
   slidesRoot.addEventListener('mouseleave', startAuto);

   renderSlides();
   startAuto();
