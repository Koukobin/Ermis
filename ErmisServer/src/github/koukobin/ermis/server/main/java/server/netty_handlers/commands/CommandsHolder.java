/* Copyright (C) 2023 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
package github.koukobin.ermis.server.main.java.server.netty_handlers.commands;

import java.lang.reflect.InvocationTargetException;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringJoiner;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.reflections.Reflections;
import org.reflections.scanners.Scanners;
import org.reflections.util.ClasspathHelper;
import org.reflections.util.ConfigurationBuilder;

import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.netty_handlers.CommandHandler;
import io.netty.buffer.ByteBuf;
import io.netty.channel.epoll.EpollSocketChannel;

/**
 * @author Ilias Koukovinis
 *
 */
public class CommandsHolder {

	private static final Logger LOGGER = LogManager.getLogger("server");

	private static final Map<ClientCommandType, ICommand> fuck = new EnumMap<>(ClientCommandType.class);

	static {
		LOGGER.debug("CommandHandler package: {}", CommandHandler.class.getPackage());

		ConfigurationBuilder confBuilder = new ConfigurationBuilder();
		confBuilder.setUrls(ClasspathHelper.forPackage(CommandHandler.class.getPackageName()));
		confBuilder.setScanners(Scanners.SubTypes);
		Reflections reflections = new Reflections(confBuilder);
		Set<Class<? extends ICommand>> classes = reflections.getSubTypesOf(ICommand.class);

		for (Class<? extends ICommand> clazz : classes) {
			try {
				ICommand command = clazz.getDeclaredConstructor().newInstance();
				fuck.put(command.getCommand(), command);

				LOGGER.debug("Command added: {}", command.getClass().getSimpleName());
			} catch (IllegalArgumentException | InvocationTargetException | NoSuchMethodException | SecurityException
					| InstantiationException | IllegalAccessException e) {
				LOGGER.fatal("Could not access constructor!", e);
				throw new RuntimeException("Could not access constructor!", e);
			}
		}

		if (classes.size() != ClientCommandType.values().length) {
			List<ClientCommandType> addedCommands = fuck.values().stream().map(ICommand::getCommand).toList();

			StringJoiner builder = new StringJoiner(", ");
			for (ClientCommandType type : ClientCommandType.values()) {
				if (!addedCommands.contains(type)) {
					builder.add(type.toString());
				}
			}
			String discrepancy = builder.toString();

			throw new RuntimeException(String.format("Client commands: %n%s%n corresponding execution not found!", discrepancy));
		}

		if (fuck.size() != ClientCommandType.values().length) {
			throw new RuntimeException("A duplicate client command type found!");
		}
	}

	/** Don't let anyone else instantiate this class */
	private CommandsHolder() {}

	public static void initialize() {
		// Helper method to load class
	}

	private static String findDiscrepancy(List<ClientCommandType> list) {
		StringJoiner builder = new StringJoiner(", ");
		for (ClientCommandType type : ClientCommandType.values()) {
			if (!list.contains(type)) {
				builder.add(type.toString());
			}
		}
		return builder.toString();
	}

	/**
	 * Attempts to find and execute command given; if command not implemented
	 * informs inquirer
	 * 
	 * @param commandType
	 * @param clientInfo
	 * @param args
	 */
	public static void executeCommand(ClientCommandType commandType, ClientInfo clientInfo, ByteBuf args) {
		EpollSocketChannel channel = clientInfo.getChannel();
		ICommand command = fuck.get(commandType);

		if (command == null) {
			ByteBuf payload = channel.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.SERVER_INFO.id);
			payload.writeInt(ServerInfoMessage.COMMAND_NOT_IMPLEMENTED.id);

			channel.writeAndFlush(payload);
			return;
		}

		command.execute(clientInfo, args);
	}

	public static ICommand getCommand(ClientCommandType commandType) {
		return fuck.get(commandType);
	}
}
