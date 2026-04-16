/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/15 20:14:51 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/16 17:24:46 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <avr/io.h>

/*
*	16MHz = 16 000 000 tics/s
*	
* 	load i = 8 tics, 4 octets = 2 tics
*	incremente + addition = 4-6 tics
*	compare = 4-8tics
*	jmp = 2 tics
*	stock volatile = 8 tics
*
*/

int	main(void) {
	DDRB |= (1 << PORTB1);
	volatile uint32_t i;
	while (1) {
		PORTB ^= (1 << PORTB1);
		for (i = 0; i < 250000; i++) {} // environ 250000 * 32 = 8 000 000 tics/s
	}
	return (0);
}

// se qui occupe 0.5s
// pour 1Hz
