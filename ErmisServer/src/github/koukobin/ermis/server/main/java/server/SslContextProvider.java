/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package github.koukobin.ermis.server.main.java.server;

import java.io.FileInputStream;
import java.security.KeyStore;
import java.util.Arrays;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.TrustManagerFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;

import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import io.netty.handler.ssl.ApplicationProtocolConfig;
import io.netty.handler.ssl.ApplicationProtocolNames;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.SslProvider;
import io.netty.handler.ssl.SupportedCipherSuiteFilter;
import io.netty.handler.ssl.ApplicationProtocolConfig.Protocol;
import io.netty.handler.ssl.ApplicationProtocolConfig.SelectedListenerFailureBehavior;
import io.netty.handler.ssl.ApplicationProtocolConfig.SelectorFailureBehavior;

/**
 * @author Ilias Koukovinis
 *
 */
public final class SslContextProvider {

	public static final SslContext sslContext;

	private SslContextProvider() {}

	static {
		try {
			char[] certificatePassword = ServerSettings.SSL.CERTIFICATE_PASSWORD.toCharArray();

			KeyStore ks = KeyStore.getInstance(ServerSettings.SSL.CERTIFICATE_TYPE);
			ks.load(new FileInputStream(ServerSettings.SSL.CERTIFICATE_LOCATION), certificatePassword);

			KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
			kmf.init(ks, certificatePassword);

			TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
			tmf.init(ks);

			sslContext = SslContextBuilder.forServer(kmf)
					.trustManager(tmf)
					.protocols(ServerSettings.SSL.getEnabledProtocols())
					.sslProvider(SslProvider.OPENSSL)
					.ciphers(Arrays.asList(ServerSettings.SSL.getEnabledCipherSuites()), SupportedCipherSuiteFilter.INSTANCE)
					.applicationProtocolConfig(
							new ApplicationProtocolConfig(Protocol.ALPN, SelectorFailureBehavior.NO_ADVERTISE,
									SelectedListenerFailureBehavior.ACCEPT, ApplicationProtocolNames.HTTP_1_1))
					.build();
		} catch (Exception e) {
			final Logger logger = LogManager.getLogger("server");
			logger.fatal(Throwables.getStackTraceAsString(e));
			throw new RuntimeException(e);
		}
	}
}
