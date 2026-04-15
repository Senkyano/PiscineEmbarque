/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/15 13:17:49 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/15 19:45:37 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <avr/io.h>
#include <util/delay.h>

int	main(void)
{
	uint8_t			compteur;
	uint8_t 		pins[] = {PORTB0, PORTB1, PORTB2, PORTB4};

	DDRB = (1 << PORTB0) | (1 << PORTB1) | (1 << PORTB2) | (1 << PORTB4);
	DDRD &= ~((1 << PORTD2) | (1 << PORTD4));
	compteur = 0;
	while (1) {
		_delay_ms(20);
		if (!(PIND & (1 << PORTD2))) {
			compteur++;
			while (!(PIND & (1 << PORTD2))) {}
		}
		if (!(PIND & (1 << PORTD4))) {
			compteur--;
			while (!(PIND & (1 << PORTD4))) {}
		}
		_delay_ms(20);
		if (compteur > 15)
			compteur = 0;
		for (uint8_t i = 0; i < 4; i++)
			(compteur & (1 << i)) ? (PORTB |= (1 << pins[i])) : (PORTB &= ~(1 << pins[i]));
	}
	return (0);
}
