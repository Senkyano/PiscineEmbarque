/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/15 20:14:51 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/16 17:54:13 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

// 15.2.1 Registers
// registre summary
void	timer_init() {
	TCCR1A |= (1 << WGM11);
	TCCR1B |= (1 << WGM13) | (1 << WGM12);

	TCCR1A |= (1 << COM1A1);//rules action

	ICR1 = 15624; // definition de la periode

	OCR1A = 1562; // rapport cyclique

	TCCR1B |= (1 << CS12) | (1 << CS10);//mask
}


void	ocr_modif_percent(uint16_t percent) {
	OCR1A = ((uint32_t)ICR1 * percent) / 100;
}

int	main(void) {
	uint16_t percent = 10;
	DDRB |= (1 << DDB1);
	DDRD &= ~((1 << PORTD2) | (1 << PORTD4));
	PORTD |= (1 << PORTD2) | (1 << PORTD4);

	timer_init();
	while (1) {
		if (!(PIND & (1 << PORTD2))) {
			_delay_ms(50);
			if (percent < 100)
				percent += 10;
			while (!(PIND & PORTD2)) {}
		}
		else if (!(PIND & (1 << PORTD4))) {
			_delay_ms(50);
			if (percent > 10)
				percent -= 10;
			while (!(PIND & PORTD4)) {}			
		}
		_delay_ms(50);
		ocr_modif_percent(percent);
	}
	return (0);
}
