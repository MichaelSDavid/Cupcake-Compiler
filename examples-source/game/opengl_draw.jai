
// NOTE(Wase): Used to fix the texture bug. 
TA :: 0.01
TB :: 0.99

draw_quad :: (position: Vector2, size: Vector2) {
	min := Sub(position, Div(size, 2))
	max := Add(position, Div(size, 2))

	glBegin(_GL_TRIANGLES)
	glVertex3f(min.x, min.y, 0)
	glVertex3f(max.x, min.y, 0)
	glVertex3f(min.x, max.y, 0)

	glVertex3f(min.x, max.y, 0)
	glVertex3f(max.x, min.y, 0)
	glVertex3f(max.x, max.y, 0)
	glEnd()
}

draw_quad_texture :: (map: *Texture_Map, position: Vector2, size: Vector2) {
	min := Sub(position, Div(size, 2))
	max := Add(position, Div(size, 2))

	glEnable(_GL_TEXTURE_2D)
	glBindTexture(_GL_TEXTURE_2D, map.id)

	glBegin(_GL_TRIANGLES)
	glTexCoord2f(TA, TA)
	glVertex3f(min.x, min.y, 0)
	glTexCoord2f(TB, TA)
	glVertex3f(max.x, min.y, 0)
	glTexCoord2f(TA, TB)
	glVertex3f(min.x, max.y, 0)

	glTexCoord2f(TA, TB)
	glVertex3f(min.x, max.y, 0)
	glTexCoord2f(TB, TA)
	glVertex3f(max.x, min.y, 0)
	glTexCoord2f(TB, TB)
	glVertex3f(max.x, max.y, 0)
	glEnd()
}

draw_quad_color :: (position: Vector2, size: Vector2, color: Vector4) {
	min := Sub(position, Div(size, 2))
	max := Add(position, Div(size, 2))

	glDisable(_GL_TEXTURE_2D)
	glBindTexture(_GL_TEXTURE_2D, 0)

	glColor4f(color.x, color.y, color.z, color.w)
	glBegin(_GL_TRIANGLES)
	glTexCoord2f(TA, TA)
	glVertex3f(min.x, min.y, 0)
	glTexCoord2f(TB, TA)
	glVertex3f(max.x, min.y, 0)
	glTexCoord2f(TA, TB)
	glVertex3f(min.x, max.y, 0)

	glTexCoord2f(TA, TB)
	glVertex3f(min.x, max.y, 0)
	glTexCoord2f(TB, TA)
	glVertex3f(max.x, min.y, 0)
	glTexCoord2f(TB, TB)
	glVertex3f(max.x, max.y, 0)
	glEnd()

	glEnable(_GL_TEXTURE_2D)
}

draw_quad_texture_color :: (map: *Texture_Map, position: Vector2, size: Vector2, color: Vector4) {
	min := Sub(position, Div(size, 2))
	max := Add(position, Div(size, 2))

	glBindTexture(_GL_TEXTURE_2D, map.id)

	glBegin(_GL_TRIANGLES)
	glColor3f(color.x, color.y, color.z)
	glTexCoord2f(TA, TA)
	glVertex3f(min.x, min.y, 0)
	glTexCoord2f(TB, TA)
	glVertex3f(max.x, min.y, 0)
	glTexCoord2f(TA, TB)
	glVertex3f(min.x, max.y, 0)

	glTexCoord2f(TA, TB)
	glVertex3f(min.x, max.y, 0)
	glTexCoord2f(TB, TA)
	glVertex3f(max.x, min.y, 0)
	glTexCoord2f(TB, TB)
	glVertex3f(max.x, max.y, 0)
	glEnd()
}

draw_background_gradient :: () {
    glDisable(_GL_TEXTURE_2D);

    p0 := make_vector2(0, 0);
    p1 := make_vector2(WINDOW_WIDTH, 0);
    p2 := make_vector2(WINDOW_WIDTH, WINDOW_HEIGHT);
    p3 := make_vector2(0, WINDOW_HEIGHT);

    c0 := make_vector3(40, 49, 95)
    c1 := make_vector3(0, 89, 131)

    c0 = Mul(Div(c0, 255), 0.3)
    c1 = Mul(Div(c1, 255), 0.7)

    glBegin(_GL_TRIANGLES)
    glColor3f(c0.x, c0.y, c0.z)
    glVertex3f(p0.x, p0.y, 0)
    glColor3f(c0.x, c0.y, c0.z)
    glVertex3f(p1.x, p1.y, 0)
    glColor3f(c1.x, c1.y, c1.z)
    glVertex3f(p2.x, p2.y, 0)

    glColor3f(c0.x, c0.y, c0.z)
    glVertex3f(p0.x, p0.y, 0)
    glColor3f(c1.x, c1.y, c1.z)
    glVertex3f(p2.x, p2.y, 0)
    glColor3f(c1.x, c1.y, c1.z)
    glVertex3f(p3.x, p3.y, 0)
    glEnd();

    glEnable(_GL_TEXTURE_2D);
}

draw_particle :: (using particle: *Particle, emitter: *Particle_Emitter) {
	size2 := make_vector2(size, size)

	min := Sub(position, Div(size2, 2))
	max := Add(position, Div(size2, 2))

	alpha: F32 = 1
    tail_time := lifetime - elapsed
    if tail_time < emitter.fadeout_period {
        t := tail_time / emitter.fadeout_period
        if t < 0 then t = 0
        if t > 1 then t = 1
        
        alpha = t
    }

	glColor4f(color.x, color.y, color.z,  color.w * alpha)
	glTexCoord2f(TA, TA)
	glVertex3f(min.x, min.y, 0)
	glTexCoord2f(TB, TA)
	glVertex3f(max.x, min.y, 0)
	glTexCoord2f(TA, TB)
	glVertex3f(min.x, max.y, 0)

	glTexCoord2f(TA, TB)
	glVertex3f(min.x, max.y, 0)
	glTexCoord2f(TB, TA)
	glVertex3f(max.x, min.y, 0)
	glTexCoord2f(TB, TB)
	glVertex3f(max.x, max.y, 0)
}

draw_particle_emitter :: (using emitter: *Particle_Emitter) {
	glBindTexture(_GL_TEXTURE_2D, texture.id);
    glBegin(_GL_TRIANGLES);
             
	for *particle: particles {
		draw_particle(particle, emitter)
	}

	glEnd();
}

draw_text :: (font: *Font_Map, text: String, position: Vector2) {
	glEnable(_GL_TEXTURE_2D)
	glBindTexture(_GL_TEXTURE_2D, font.texture.id)
    glBegin(_GL_QUADS)
             
    x: F32 = position.x
    y: F32 = position.y

	for char: text {
		if char < 32 || char > 128 then continue

		quad: stbtt_aligned_quad
        stbtt_GetBakedQuad(font.characters.data, 512, 512, char - 32, *x, *y, *quad, 1)
        glTexCoord2f(quad.s0, quad.t0) glVertex3f(quad.x0, quad.y0, 0)
        glTexCoord2f(quad.s1, quad.t0) glVertex3f(quad.x1, quad.y0, 0)
        glTexCoord2f(quad.s1, quad.t1) glVertex3f(quad.x1, quad.y1, 0)
        glTexCoord2f(quad.s0, quad.t1) glVertex3f(quad.x0, quad.y1, 0)
	}

	glEnd();
}


draw_text_center :: (font: *Font_Map, text: String, position: Vector2) {
    x: F32 = position.x
    y: F32 = position.y

	for char: text {
		if char < 32 || char > 128 then continue

		quad: stbtt_aligned_quad
        stbtt_GetBakedQuad(font.characters.data, 512, 512, char - 32, *x, *y, *quad, 1)
	}

	width := x - position.x
	height := y - position.y

	draw_text(font, text, Sub(position, Div(make_vector2(width, height), 2)))
}